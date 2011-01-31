module Palmade::Cableguy
  class Builders::CableTemplate < Cable
    add_as :template

    def configure(cabler, cabling, target)
      cabler.say_with_time "configuring #{@args[0]}" do
        unless @args[1].nil?
          target_path = File.join(cabler.app_root, @args[1], @args[0])
        else
          target_path = nil
        end

        install_template(@args[0], cabler, cabling, target, target_path)
      end
    end
  end
end

