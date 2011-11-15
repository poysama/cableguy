module Palmade::Cableguy
  class DB
    attr_reader :database

    def initialize(cabler)
      @cabler = cabler
      @opts = { :logger => @cabler.logger,
                :sql_log_level => :debug }
      @database = nil
    end

    def boot
      @database = Sequel.sqlite(@cabler.db_path, @opts)
      @group = ""
      @prefix_stack = []
      @dataset = @database[:cablingdatas]
    end

    def final_key(key)
      unless @prefix_stack.empty?
        @prefix_stack.push(key)
        key = nil
      end

      key ||= @prefix_stack.join('.')
    end

    def set(key, value, group = nil)
      group ||= @group
      key = final_key(key)

      @dataset.insert(:key => key, :value => value, :group => group)

      stack_pop
    end

    def delete(key, value)
      key = final_key(key)
      @dataset.filter(:key => key).delete
      stack_pop
    end

    def update(key, value, set = nil)
      key = final_key(key)
      @dataset.filter(:key => key).update(:value => value)
      stack_pop
    end

    def group(group = nil, &block)
      @group = group

      yield
    end

    def globals(&block)
      @group = "globals"

      yield
    end

    def prefix(prefix, &block)
      @prefix_stack.push(prefix)
      yield

      stack_pop
    end

    def stack_pop
      @prefix_stack.pop
    end

    def get(key, group = nil)
      group ||= @cabler.group.to_s

      val = @dataset.where(:key => key, :group => group)

      if val.empty?
        val = @dataset.where(:key => key, :group => "globals")
      end

      val.first[:value] rescue raise "key \'#{key}\' cannot be found!"
    end

    def get_children(key, group = nil)
      group ||= @cabler.group.to_s
      values = []

      res = @dataset.where(:key.like("#{key}%"), :group => group)

      if res.empty?
        res = @dataset.where(:key.like("#{key}%"), :group => "globals")
      end

      key = key.split('.')

      res.each do |r|
        res_key = r[:key].split('.')
        res_key = (res_key - key).shift
        values.push(res_key)
      end

      values & values rescue raise "no values for \'#{key}\'!"
    end

    def create_table_if_needed
      @database.create_table! :cablingdatas do
        String :key
        String :value
        String :group
      end
    end
  end
end
