module Palmade::Cableguy
  class Runner
    def self.run(app_root, cmd, options)
      if options[:path].nil?
        if ENV.include?("CABLING_PATH")
          options[:path] = ENV["CABLING_PATH"]
        elsif File.exist?(File.expand_path('~/cabling'))
          options[:path] = File.expand_path('~/cabling')
        elsif File.exist?("/var/cabling")
          options[:path] = "/var/cabling"
        elsif File.exist?("/etc/cabling")
          options[:path] = "/etc/cabling"
        else
          raise "You don't seem to have any paths for cabling.\n"
        end
      end

      if options[:target].nil?
        if ENV.include?("CABLING_TARGET")
          options[:target] = ENV["CABLING_TARGET"]
        else
          options[:target] = 'development'
        end
      end

      if options[:location].nil?
        if ENV.include?("CABLING_LOCATION")
          options[:location] = ENV["CABLING_LOCATION"]
        else
          options[:location] = nil
        end
      end

      ca = Cabler.new(app_root, options)

      case cmd
      when 'migrate'
        ca.boot.migrate
      else
        ca.boot.configure
      end
    end
  end
end
