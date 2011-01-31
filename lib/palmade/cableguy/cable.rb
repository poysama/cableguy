module Palmade::Cableguy
  class Cable
    attr_reader :args

    @@builders = { }
    def self.builders
      @@builders
    end

    def self.add_as(key, klass = nil)
      builders[key] = klass || self
    end

    def self.build_key(klass = nil)
      builders.index(klass || self)
    end

    def self.build(what, *args, &block)
      if builders.include?(what)
        builders[what].new(*args, &block)
      else
        raise ArgumentError, "Unknown builder: #{what} -- supports: #{supported_builders.join(', ')}"
      end
    end

    def self.supported_builders
      builders.keys
    end

    def initialize(*args, &block)
      @args = args
      @block = block
    end

    def configure(cabler, cabling, target, &block)
      puts "Not implemented: #{self.class.build_key}"
    end

    protected

    def install_template(template_file, cabler, cabling, target, target_path = nil)
      app_root = cabler.app_root

      template_path = File.join(app_root, DEFAULT_TEMPLATES_PATH, template_file)
      if target_path.nil?
        target_path = File.join(app_root, DEFAULT_TARGET_PATH, template_file)
      end

      if File.exists?(template_path)
        cabler.say "installing template file: #{template_file}", true

        tb = TemplateBinding.new(self, cabler, cabling, target)
        tb.install(template_path, target_path)
      else
        raise ArgumentError, "template file #{template_file} not found in #{DEFAULT_TEMPLATES_PATH}"
      end
    end
  end

  Builders.load_all_builders
end

