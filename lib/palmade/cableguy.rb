require 'rubygems'
require 'benchmark'
require 'fileutils'
require 'sequel'
require 'logger'
require File.join(File.dirname(__FILE__), 'cableguy/version')

module Palmade
  module Cableguy
    autoload :Builders, File.join(File.dirname(__FILE__), 'cableguy/builders')
    autoload :Cable, File.join(File.dirname(__FILE__), 'cableguy/cable')
    autoload :Cabler, File.join(File.dirname(__FILE__), 'cableguy/cabler')
    autoload :CableConfigurator, File.join(File.dirname(__FILE__), 'cableguy/cable_configurator')
    autoload :Configurator, File.join(File.dirname(__FILE__), 'cableguy/configurator')
    autoload :Constants, File.join(File.dirname(__FILE__), 'cableguy/constants')
    autoload :DB, File.join(File.dirname(__FILE__), 'cableguy/db')
    autoload :Migration, File.join(File.dirname(__FILE__), 'cableguy/migration')
    autoload :Runner, File.join(File.dirname(__FILE__), 'cableguy/runner')
    autoload :TemplateBinding, File.join(File.dirname(__FILE__), 'cableguy/templatebinding')
    autoload :Utils, File.join(File.dirname(__FILE__), 'cableguy/utils')

    DEFAULT_CABLEGUY_PATH = "config/cableguy.rb"
    DEFAULT_TEMPLATES_PATH = "config/templates"
    DEFAULT_TARGET_PATH = "config"

    class CableguyError < StandardError; end
    class NotImplemented < CableguyError; end
    class MissingFile < CableguyError; end

    def self.check_requirements(app_root)
      boot(app_root).check_requirements
    end

    def self.configure(app_root)
      boot(app_root).configure
    end

    def self.require_erb
      require 'erb'
    end
  end
end

