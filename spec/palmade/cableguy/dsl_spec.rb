module Palmade::Cableguy
  describe Dsl do
    before(:all) do
      @cablefile = File.read(File.join('spec/fixtures/Cablefile'))
      @dsl       = Dsl.new(@cablefile)
    end

    describe "#source" do
      context "with an argument" do
        it "should not raise an error" do
          expect { @dsl.source('http://couchdb.example/database/document') }.to_not raise_error
        end

        it "should assign the source" do
          url = 'http://couchdb.example/database/document'
          @dsl.source(url).should == @dsl.source
        end
      end
    end

    describe "#template" do
      it "should call the template builder" do
        Builders::Template.should_receive(:build).with('template', @dsl.source)
        @dsl.template('template')
      end
    end

    describe "#directory" do
      context "with a single argument" do
        it "should call the directory builder with a string" do
          Builders::Directory.should_receive(:build).with('tmp')
          @dsl.directory('tmp')
        end
      end

      context "with multiple arguments" do
        it "should call the directory builder with an array" do
          Builders::Directory.should_receive(:build).with(['log', 'tmp/pids'])
          @dsl.directory(['log', 'tmp/pids'])
        end
      end
    end

    describe "#link" do
      it "should call the link builder" do
        Builders::Link.should_receive(:build).with('/opt/test', '/opt/test2')
        @dsl.link('/opt/test', '/opt/test2')
      end
    end

    it "should evaluate the configfile" do
      expect { Dsl.evaluate(@cablefile) }.to_not raise_exception
    end
  end
end
