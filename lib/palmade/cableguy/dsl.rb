module Palmade::Cableguy
  class Dsl
    def self.evaluate(config)
      new(config).evaluate
    end

    def initialize(config)
      @config = config
    end

    def evaluate
      instance_eval @config
    end

    def source(url = '')
      @source ||= url
    end

    def template_path(path)
      Palmade::Cableguy.template_path = path
    end

    def template(template)
      Builders::Template.build(template, source).build!
    end

    def directory(paths)
      Builders::Directory.build(paths)
    end

    def link(source, destination)
      Builders::Link.build(source, destination)
    end
  end
end
