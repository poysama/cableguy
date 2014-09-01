module Palmade::Cableguy
  describe TemplateBinding do
    before(:each) do
      Palmade::Cableguy.template_path = 'config/templates'
      FileUtils.mkdir_p(Palmade::Cableguy.template_path)
      FileUtils.touch(File.join(Palmade::Cableguy.template_path, 'test.yml'))

      @template_builder = Palmade::Cableguy::Builders::Template.new('test.yml', 'http://test.example/database/document')
      # let us simulate build!
      @template_builder.response = <<-RESPONSE
        {
          "server": {
            "url": "http://test.example",
            "port": "1234",
            "timeouts": {
              "big": "300",
              "small": "100"
            }
          },

          "hello": "world"
        }
      RESPONSE

      @template_builder.parse_response
      @template_binding = TemplateBinding.new(@template_builder)
      @template = <<-TEMPLATE
        url: {server.url}
        port: {server.port}
        message: {hello}
        timeouts:
          big: {server.timeouts.big}
          small: {server.timeouts.small}
      TEMPLATE

      File.open(File.join(Palmade::Cableguy.template_path,'test.yml'), "w") { |f| f.write(@template) }

      @result   = <<-RESULT
        url: http://test.example
        port: 1234
        message: world
        timeouts:
          big: 300
          small: 100
      RESULT

    end

    it "should parse the template" do
      @template_binding.parse.should == @result
    end

    it "should write the correct file" do
      @template_binding.install
      File.read(@template_binding.config).should == @result
    end

    after(:each) do
      FileUtils.rm_rf(Palmade::Cableguy.template_path)
      FileUtils.rm_rf('config')
    end
  end
end
