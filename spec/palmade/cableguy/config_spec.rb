module Palmade::Cableguy
  describe Config do
    let(:cablefile) {
      File.join(Palmade::Cableguy::WORK_PATH, Config::CONFIG_FILE)
    }

    describe "a valid Cablefile" do
      before(:each) do
        FileUtils.touch(cablefile)
      end

      it "should exist under cableguy's work path" do
        subject.config_exists?.should be true
      end

      after do
        FileUtils.rm(cablefile)
      end
    end

    it "should load the configfile for evaluation" do
      Dsl.should_receive(:evaluate)
      subject.load_file
    end
  end
end
