require 'rubygems'
require 'fileutils'
require 'palmade/cableguy/version'

module Palmade
  module Cableguy
    WORK_PATH = Dir.pwd

    @@template_path = 'config/templates'

    autoload :Builders,        'palmade/cableguy/builders'
    autoload :Config,          'palmade/cableguy/config'
    autoload :Cli,             'palmade/cableguy/cli'
    autoload :Dsl,             'palmade/cableguy/dsl'
    autoload :TemplateBinding, 'palmade/cableguy/template_binding'

    def self.template_path; @@template_path end
    def self.template_path= path; @@template_path = path end
  end

end

