module Palmade::Cableguy
  class Builders::CableMove < Cable
    add_as :move

    def configure(cabler, cabling, target)
      cabler.say_with_time "moving #{@args.join(' -> ')}" do
        FileUtils.mv(@args.shift, @args.shift)
      end
    end
  end
end

