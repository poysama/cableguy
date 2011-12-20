module Palmade::Cableguy
  class DB
    attr_reader :database

    def initialize(cabler)
      @cabler = cabler
      @database = nil
      @sql_options = { :logger => @cabler.logger, :sql_log_level => :info }

      if @cabler.options[:verbose]
        @sql_options[:sql_log_level] = :debug
      end
    end

    def boot
      @database = Sequel.sqlite(@cabler.db_path, @sql_options)
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

    def has_key?(key, group)
      group ||= @cabler.group.to_s

      val = @dataset.where(:key => key, :group => group).count

      if val == 0
        val = @dataset.where(:key => key, :group => "globals").count

        val == 0 ? true : false
      else
        true
      end
    end

    def get(key, group = nil)
      group ||= @cabler.group.to_s

      val = @dataset.where(:key => key, :group => group)

      if val.empty?
        val = @dataset.where(:key => key, :group => "globals")
      end

      if val.count > 0
        val.first[:value]
      else
        raise "key \'#{key}\' cannot be found!"
      end
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

      if values.count > 0
        values & values
      else
        raise "no values for \'#{key}\'!"
      end
    end

    def create_table_if_needed
      if @database.tables.include? :cablingdatas
        @database.drop_table :cablingdatas
      end

      @database.create_table :cablingdatas do
        String :key
        String :value
        String :group
      end
    end
  end
end
