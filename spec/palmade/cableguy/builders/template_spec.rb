module Palmade::Cableguy::Builders
  describe Template do
    before(:each) do
      @source           = double("http://example.com")
      @template_builder = Template.build('test.yml', @source)
    end

    it "should load data from the source" do
      RestClient.stub(:get).with(@source)
      @template_builder.load_data
    end

    it "should parse the loaded data to json" do
      JSON.should_receive(:parse).with("{}")
      @template_builder.response = "{}"
      @template_builder.parse_response
    end

    context "a template should exist" do
      before(:all) do
        Palmade::Cableguy.template_path = 'config/templates'
        FileUtils.mkdir_p(Palmade::Cableguy.template_path)
        FileUtils.touch(File.join(Palmade::Cableguy.template_path, 'test.yml'))
      end

      it "should find a template under template path" do
        @template_builder.exists?.should be true
      end

      after do
        FileUtils.rm_rf(Palmade::Cableguy.template_path)
      end
    end
  end
end
