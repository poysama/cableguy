module Palmade::Cableguy
  class Migration
    attr_reader :cabler
    attr_reader :db

    def initialize(cabler)
      @cabler = cabler

      @db = @cabler.db
      @cabling_path = @cabler.cabling_path
      @utils = Palmade::Cableguy::Utils
    end

    def boot
      @db.create_table_if_needed

      file_stack = []

      sort_directories.each do |p|
        path = File.join(@cabling_path, p)

        if p == 'targets'
          if !@cabler.location.nil? && @cabler.location != @cabler.target
            f = File.join(path, "#{@cabler.target}_#{@cabler.location}.rb")
          else
            f = File.join(path, "#{@cabler.target}.rb")
          end

          if File.exists?(f)
            require f
            file_stack.push(f)
          else
            raise "File #{f} doesn't exist!"
          end
        elsif p == '.'
          if File.exist?(File.join(path, 'custom.rb'))
            f = Dir["#{path}/custom.rb"].shift
            require f
            file_stack.push(f)
          end
        else
          Dir["#{path}/*.rb"].each do |d|
            require d
            file_stack.push(d)
          end
        end

        file_stack.each do |f|
          class_name = File.basename(f).chomp(".rb")
          camelized_class_name = (@utils.camelize(class_name))
          klass = Palmade::Cableguy::Migrations.const_get(camelized_class_name)
          k = klass.new(@cabler)
          k.migrate!
        end
        file_stack.clear
      end
    end

    def sort_directories
      dir_stack = ["base", "targets", '.']
    end

    def migrate!
      raise "class #{self.class.name} doesn't have a migrate method. Override!"
    end

    def set(key, value, set = nil)
      @db.set(key, value, set)
    end

    def group(group, &block)
      @group = group
      @db.group(@group, &block)
    end

    def globals(&block)
      @db.globals(&block)
    end

    def prefix(prefix, &block)
      @db.prefix(prefix, &block)
    end

    def delete_key(key, group = nil)
      @db.delete_key(key, group)
    end

    def update(key, value)
      @db.update(key, value)
    end
  end
end
