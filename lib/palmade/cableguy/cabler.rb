module Palmade::Cableguy
  class Cabler
    attr_reader :app_root
    attr_reader :builds
    attr_reader :target
    attr_accessor :targets
    attr_accessor :app_name

    def initialize(app_root)
      @app_root = app_root
      @target = :development
      @builds = nil
      @targets = [ :development ]

      @configurator_path = File.join(@app_root, DEFAULT_CABLEGUY_PATH)
      @configurator = CableConfigurator.new

      if ENV.include?('CABLING_TARGET')
        @target = ENV['CABLING_TARGET']
      end

      if File.exists?(File.join(@app_root, DEFAULT_CABLING_PATH))
        @cabling_path = File.join(@app_root, DEFAULT_CABLING_PATH)
      elsif ENV.include?('CABLING_PATH')
        @cabling_path = ENV['CABLING_PATH']
      elsif File.exists?(File.expand_path('~/.cabling.yml'))
        @cabling_path = File.expand_path('~/.cabling.yml')
      elsif File.exists?('/etc/cabling.yml')
        @cabling_path = '/etc/cabling.yml'
      else
        @cabling_path = nil
      end

      @cabling = Cabling.new
    end

    def boot
      # checks for config/cabling.rb
      if !@cabling_path.nil? && File.exists?(@cabling_path)
        @cabling.load_from_yml(@cabling_path)
      else
        raise MissingFile, "Required cabling file (#{@cabling_path}) not found!"
      end

      # checks for config/cableguy.rb
      if File.exists?(@configurator_path)
        @configurator.configure(@configurator_path)
      else
        raise MissingFile, "Required cableguy file (#{@configurator_path}) not found!"
      end

      # set target if target exists in cabling globals
      if @cabling.globals.include?('target')
        @target = @cabling.globals['target']
      end

      self
    end

    def configure
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

