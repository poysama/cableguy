module Palmade::Cableguy
  class Cabling < ConfigHelper
    def globals
      self['globals']
    end

    def applications
      self['applications']
    end

    def app(app_name, merge_globals = true)
      @apps_config = { } unless defined?(@apps_config)

      if merge_globals
        if @apps_config.include?(app_name)
          @apps_config[app_name]
        else
          glob = globals
          if applications.include?(app_name)
            this_app = (applications[app_name] || applications).dup
            this_app = self.class.new if this_app.nil? || this_app.empty?

            this_app.update!(globals)

            @apps_config[app_name] = this_app
          else
            raise ArgumentError, "application #{app_name} not defined in cabling file"
          end
        end
      else
        applications[app_name]
      end
    end
  end
end

