module Palmade::Cableguy
  class Cabler
    include Constants

    attr_reader :app_root
    attr_reader :builds
    attr_reader :cabling_path
    attr_reader :target
    attr_reader :location
    attr_reader :database
    attr_reader :cabler
    attr_reader :logger
    attr_reader :options
    attr_reader :db_path
    attr_reader :db
    attr_accessor :targets
    attr_accessor :app_name

    def initialize(app_root, options)
      @options = options
      @app_root = app_root
      @cabling_path = @options[:path]
      @target = @options[:target]
      @location = @options[:location]
      @builds = nil
      @targets = [ :development ]
      @logger = Logger.new($stdout)
      @db_path = File.join(@cabling_path, DB_DIRECTORY, "#{@target}.#{DB_EXTENSION}")
      @db = Palmade::Cableguy::DB.new(self)
    end

    def boot
      @database = @db.boot

      self
    end

    def migrate
      init_file = File.join(@cabling_path, 'init.rb')
      require init_file if File.exist?(init_file)

      Migration.new(self).boot
    end

    def configure
      @configurator = CableConfigurator.new
      @configurator_path = File.join(@app_root, DEFAULT_CABLEGUY_PATH)

      # checks for config/cableguy.rb
      if File.exists?(@configurator_path)
        @configurator.configure(@configurator_path)
      else
        raise MissingFile, "Required cableguy file (#{@configurator_path}) not found!"
      end

      check_requirements

      build_setups.each do |s|
        s.configure(self, @cabling, @target)
      end
    end

    def check_requirements
      if @configurator.include?(:requirements)
        @configurator.requirements(self, @cabling, @target)
      end
    end

    def say(message, subitem = false)
      puts "#{subitem ? "   ->" : "--"} #{message}"
    end

    def say_with_time(message)
      say(message)
      result = nil
      time = Benchmark.measure { result = yield }
      say "%.4fs" % time.real, :subitem
      say("#{result} rows", :subitem) if result.is_a?(Integer)
      result
    end

    def require_cables(path)
      if path =~ /\//
        require(path)
      else
        require(File.join(@app_root, DEFAULT_CABLES_PATH, path))
      end
    end

    protected

    def build_setups
      if @builds.nil?
        @configurator.setup_cabling(self, @cabling, @target)
        @builds = @configurator.setups.collect do |s|
          Cable.build(s[0], *s[1], &s[2])
        end
      else
        @builds
      end
    end
  end
end

