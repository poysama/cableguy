module Palmade::Cableguy
  class Builders::CableChmod < Cable
    add_as :chmod

    def configure(cabler, cabling, target)
      cabler.say_with_time "changing permissions #{args.join(' -> ')}" do
        FileUtils.chmod(@args.shift.to_i(8), File.join(cabler.app_root, @args.shift))
      end
    end
  end
end

