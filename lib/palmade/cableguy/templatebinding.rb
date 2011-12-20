module Palmade::Cableguy
  class TemplateBinding
    attr_reader :cable
    attr_reader :cabler
    attr_reader :cabling
    attr_reader :arg_hash
    attr_reader :target
    attr_reader :location
    attr_reader :db
    attr_reader :reserved_keys
    attr_accessor :output_buffer

    def initialize(cable, cabler, cabling, target)
      @cable = cable
      @cabler = cabler
      @cabling = cabling
      @target = target
      @location = @cabler.location
      @arg_hash = @cable.args[2]
      @db = @cabler.db
      @key_prefix = []
      @reserved_keys = ['target', 'location']
    end

    def join_keys(key)
      "#{@key_prefix.join('.')}.#{key}"
    end

    def has_key?(key, group = nil)
      if !@key_prefix.empty?
        key = join_keys(key)
      end

      @db.has_key?(key, group)
    end

    def get(key, group = nil)
      if !@key_prefix.empty?
        key = join_keys(key)
      end

      @db.get(key, group)
    end

    def get_children(key, group = nil, &block)
      if block_given?
        fill_key_prefix(key)

        yield @db.get_children(key, group)
        @key_prefix.clear
      else
        @db.get_children(key, group)
      end
    end

    def get_each_child(key, group = nil, &block)
      if block_given?
        fill_key_prefix(key)

        children = @db.get_children(key, group)

        children.each do |c|
          yield c
        end

        @key_prefix.clear
      else
        @db.get_children(key, group)
      end
    end

    def fill_key_prefix(key)
      key.split('.').each do |k|
        @key_prefix << k
      end
    end

    def parse(file_path)
      Palmade::Cableguy.require_erb
      fcontents = File.read(file_path)

      parsed = ERB.new(fcontents, nil, "-%>", "@output_buffer").result(binding)
      parsed = special_parse(parsed, [ '{', '}' ], false)
    end

    def special_parse(parsed, delim = [ '{', '}' ], cabling_only = false)
      delim0 = "\\#{delim[0]}"
      delim1 = "\\#{delim[1]}"

      parsed = parsed.gsub(/#{delim0}(.+)#{delim1}/) do |match|
        found = $1

        if @reserved_keys.include?(found)
          eval_ret = self.send(found)
        else
          eval_ret = get(found)
        end
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
  end
end

