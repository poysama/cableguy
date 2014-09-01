require 'erb'

module Palmade::Cableguy
  class TemplateBinding
    attr_reader :template
    attr_reader :config

    def initialize(template_builder)
      @result   = template_builder.result
      @template = template_builder.template
      @config   = template_builder.config
      @eval_ret = nil
    end

    def parse
      fcontents = File.read(template)

      parsed = ERB.new(fcontents, nil, "-%>", "@output_buffer").result(binding)
      parsed = special_parse(parsed, [ '{', '}' ], false)
    end

    def special_parse(parsed, delim = [ '{', '}' ], cabling_only = false)
      delim0 = "\\#{delim[0]}"
      delim1 = "\\#{delim[1]}"

      parsed = parsed.gsub(/#{delim0}(.+)#{delim1}/) do |match|
        found = $1

        @eval_ret = @result

        found.split('.').each do |meth|
          @eval_ret = @eval_ret[meth]
        end

        @eval_ret
      end
    end

    def install
      File.open(config, 'w') do |f|
        f.write(parse)
      end
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
  end
end

