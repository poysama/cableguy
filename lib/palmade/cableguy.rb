require 'benchmark'
require 'fileutils'

module Palmade
  module Cableguy
    autoload :Builders, File.join(File.dirname(__FILE__), 'cableguy/builders')
    autoload :Cable, File.join(File.dirname(__FILE__), 'cableguy/cable')
    autoload :Cabler, File.join(File.dirname(__FILE__), 'cableguy/cabler')
    autoload :CableConfigurator, File.join(File.dirname(__FILE__), 'cableguy/cable_configurator')
    autoload :Cabling, File.join(File.dirname(__FILE__), 'cableguy/cabling')
    autoload :Configurator, File.join(File.dirname(__FILE__), 'cableguy/configurator')
    autoload :ConfigHelper, File.join(File.dirname(__FILE__), 'cableguy/config_helper')
    autoload :TemplateBinding, File.join(File.dirname(__FILE__), 'cableguy/templatebinding')

    DEFAULT_CABLEGUY_PATH = "config/cableguy.rb"
    DEFAULT_CABLING_PATH = "config/cabling.yml"
    DEFAULT_TEMPLATES_PATH = "config/templates"
    DEFAULT_TARGET_PATH = "config"
    DEFAULT_CABLES_PATH = "config/cables"

    class CableguyError < StandardError; end
    class NotImplemented < CableguyError; end
    class MissingFile < CableguyError; end

    def self.check_requirements(app_root)
      boot(app_root).check_requirements
    end

    def self.configure(app_root)
      boot(app_root).configure
    end

    def self.boot(app_root)
      ca = Cabler.new(app_root)
      ca.boot
    end

    def self.require_erb
      require 'erb'
    end
  end
end

