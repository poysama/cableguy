module Palmade::Cableguy
  class Builders::CableSymlink < Cable
    add_as :symlink

    def configure(cabler, cabling, target)

    source = @args.shift
    destination = @args.shift
      cabler.say_with_time "creating symlink #{source} -> #{destination}" do
        FileUtils.ln_s(source, destination, :force => true)
      end
    end
  end
end

