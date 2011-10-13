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
      @key_prefix = ""
      @dataset = @database[:cablingdatas]
    end

    def final_key(key)
      unless @prefix_stack.empty?
        @prefix_stack.push(key)
        key = nil
      end

      key ||= @prefix_stack.join('.')
    end

    def set(key, value, set = nil)
      set ||= @group
      key = final_key(key)
      @dataset.insert(:key => key, :value => value, :set => set)
      stack_pop
    end

    def get(key)
      value_of(key)
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

    def applications(&block)
      @group = "applications"
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

    def value_of(key)
      if key.scan(/\A#{@cabler.app_name.to_s}/).empty?
        key = @cabler.app_name.to_s + '.' + key
      end

      val = @dataset.where(:key => key, :set => 'applications')

      if val.empty?
        key.slice!(0, key.index('.') + 1)
        val = @dataset.where(:key => key, :set => 'globals')
      end

      val.first[:value] rescue raise "key \'#{key}\' cannot be found!"
    end

    def values_of(key, prefix = false)
      values = {}

      @key_prefix = key if prefix

      res = @dataset.where(:key.like("#{key}%"))

      if res.empty?
        key.slice!(0, key.index('.') + 1)
        res = @dataset.where(:key.like("#{key}%"))
      end

      res.each do |r|
        res_key = r[:key].split('.')
        key.split('.').count.times do
          res_key.delete_at(0)
        end
        values[res_key.shift.to_sym] = r[:value]
      end
      values rescue raise "no values for \'#{key}\'!"
    end

    def create_table_if_needed
      @database.create_table! :cablingdatas do
        String :key
        String :value
        String :set
      end
    end
  end
end
