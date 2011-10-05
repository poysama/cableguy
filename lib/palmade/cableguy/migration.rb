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

      sort_directories.each do |p|
        path = File.join(@cabling_path, p)

        if p == 'targets'
          if !@cabler.location.nil?
            f = File.join(path, "#{@cabler.target}_#{@cabler.location}.rb")
          else
            f = File.join(path, "#{@cabler.target}.rb")
          end

          if File.exists?(f)
            require f
          else
            raise "File #{f} doesn't exist!"
          end
        else
          f = Dir["#{path}/*.rb"].first
          require f
        end

        class_name = File.basename(f).chomp(".rb")
        camelized_class_name = (@utils.camelize(class_name))
        klass = Palmade::Cableguy::Migrations.const_get(camelized_class_name)
        k = klass.new(@cabler)
        k.migrate!
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
      @db.group(group, &block)
    end

    def prefix(prefix, &block)
      @db.prefix(prefix, &block)
    end

    def delete(key, value = nil)
      @db.delete(key, value)
    end

    def update(key, value)
      @db.update(key, value)
    end
  end
end
