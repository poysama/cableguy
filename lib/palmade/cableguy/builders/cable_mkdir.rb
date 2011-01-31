module Palmade::Cableguy
  class Builders::CableMkdir < Cable
    add_as :mkdir

    def configure(cabler, cabling, target)
      cabler.say_with_time "mkdir #{@args.join(' ')}" do
        @args.each do |path|
          FileUtils.mkdir_p(File.join(cabler.app_root, path))
        end
      end
    end
  end
end

