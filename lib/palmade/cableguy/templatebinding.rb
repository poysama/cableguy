module Palmade::Cableguy
  class TemplateBinding
    attr_reader :cable
    attr_reader :cabler
    attr_reader :cabling
    attr_reader :target
    attr_reader :arg_hash

    attr_accessor :output_buffer

    def initialize(cable, cabler, cabling, target)
      @cable = cable
      @cabler = cabler
      @cabling = cabling
      @target = target
      @arg_hash = @cable.args[2]
    end


    def parse(file_path)
      Palmade::Cableguy.require_erb
      fcontents = File.read(file_path)

      parsed = ERB.new(fcontents, nil, "-%>", "@output_buffer").result(binding)
      parsed = special_parse(parsed, [ '{', '}' ], false)
      parsed = special_parse(parsed, [ '%', '%' ], true)
    end

    def special_parse(parsed, delim = [ '{', '}' ], cabling_only = false)
      delim0 = "\\#{delim[0]}"
      delim1 = "\\#{delim[1]}"
      parsed = parsed.gsub(/#{delim0}(.+)#{delim1}/) do |match|
        found = $1
        if cabling_only
          if respond_to?(found)
            eval_ret = self.send(found)
          elsif !cabler.app_name.nil?
            eval_ret = self.send(cabler.app_name)[found.strip]
          else
            eval_ret = cabling[found.strip]
          end
        else
          if found[0,1] == '['
            if cabler.app_name.nil?
              eval_ret = self.instance_eval("cabling#{found}")
            else
              eval_ret = self.instance_eval("#{cabler.app_name}#{found}")
            end
          else
            eval_ret = self.instance_eval(found)
          end
        end
        eval_ret.to_s.strip
      end
    end

    def install(source_file, target_file)
      parsed = parse(source_file)

      File.open(target_file, 'w') do |f|
        f.write(parsed)
      end
      target_file
    end

    protected

    def concat(buffer)
      output_buffer.concat(buffer)
    end

    def capture(*args, &block)
      with_output_buffer { block.call(*args) }
    end

    def with_output_buffer(buf = '') #:nodoc:
      self.output_buffer, old_buffer = buf, output_buffer
      yield
      output_buffer
    ensure
      self.output_buffer = old_buffer
    end

    def method_missing(method, *args, &block)
      if cabler.targets.include?(method)
        if method == target
          concat(capture(*args, &block))
        end
      elsif cabling['applications'].include?(method.to_s) &&
          args.empty?
        cabling.app(method.to_s)
      else
        super
      end
    end
  end
end

