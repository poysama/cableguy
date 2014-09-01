module Palmade::Cableguy
  class Config
    CONFIG_FILE = 'Cablefile'

    def config_exists?
      File.exist? CONFIG_FILE
    end

    def load_file
      Dsl.evaluate(CONFIG_FILE)
    end
  end
end
