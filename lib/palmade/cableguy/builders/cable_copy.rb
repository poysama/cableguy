module Palmade::Cableguy
  class Builders::CableCopy < Cable
    add_as :copy

    def configure(cabler, cabling, target)
      cabler.say_with_time "copying #{@args.join(' -> ')}" do
        FileUtils.cp(@args.shift, @args.shift)
      end
    end
  end
end

