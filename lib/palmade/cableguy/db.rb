module Palmade::Cableguy
  class DB
    def boot(cabler)
      @group = ""
      @prefix_stack = []
      @key_prefix = ""

      @db = Sequel.sqlite(cabler.db_path, :logger => cabler.logger , :sql_log_level => :debug)
      create_table_if_needed

      @database = @db[:cablingdatas]
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
      @database.insert(:key => key, :value => value, :set => set)
      stack_pop
    end

    def get(key)
      value_of(key)
    end

    def delete(key, value)
      key = final_key(key)
      @database.filter(:key => key).delete
      stack_pop
    end

    def update(key, value, set = nil)
      key = final_key(key)

      @database.filter(:key => key).update(:value => value)
      stack_pop
    end

    def group(group, &block)
      @group = group
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
      key = @key_prefix + '.' + key unless @key_prefix.empty?

      val = @database.where(:key => key)

      if val.empty?
        key.slice!(0, key.index('.') + 1)
        val = @database.where(:key => key)
      end
      val.first[:value] rescue raise "key \'#{key}\' cannot be found!"
    end

    def values_of(key, prefix = false)
      values = {}

      @key_prefix = key if prefix

      res = @database.where(:key.like("#{key}%"))

      if res.empty?
        key.slice!(0, key.index('.') + 1)
        res = @database.where(:key.like("#{key}%"))
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

    private

    def create_table_if_needed
      unless @db.table_exists?(:cablingdatas)
        @db.create_table :cablingdatas do
          String :key
          String :value
          String :set
        end
      end
    end
  end
end
