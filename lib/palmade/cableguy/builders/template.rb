require 'json'
require 'rest_client'

module Palmade::Cableguy::Builders
  class Template
    attr_reader   :template
    attr_reader   :config
    attr_accessor :result
    attr_accessor :response
    attr_accessor :template_path

    def self.build(template, source)
      self.new(template, source)
    end

    def initialize(template, source)
      @config   = File.join('config', template)
      @template = File.join(Palmade::Cableguy.template_path, template)
      @response = nil
      @source   = source
      @result   = nil
    end

    def build!
      load_data
      parse_response
      Palmade::Cableguy::TemplateBinding.new(self).install
    end

    def load_data
      @response = RestClient.get(@source)
    end

    def parse_response
      @result = JSON.parse(@response)
    end

    def exists?
      File.exist?(@template)
    end
  end
end
