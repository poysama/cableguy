require 'yaml'

module Palmade::Cableguy
  class ConfigHelper
    class << self
      def load_from_yml(yml_path, *args, &block)
        returning(new(*args)) { |c| yield(c) if block_given?; c.load_from_yml(yml_path) }
      end

      def load_from_hash(config_hash, *args, &block)
        returning(new(*args)) { |c| yield(c) if block_given?; c.load_from_hash(config_hash) }
      end

      def load_from_defaults
        returning(new) { |c| c.load_from_defaults }
      end
    end

    def initialize(casens = true, options = { })
      @final = false
      @casens = casens
      @config = { }

      update!(options)
    end

    def load_from_yml(yml_path)
      update!(YAML.load_file(yml_path))
    end

    def load_from_hash(config_hash)
      update!(config_hash)
    end

    def load_from_defaults
      @config = { }
    end

    def [](key)
      @config[convert_key(key)]
    end

    def []=(key, val)
      @config[convert_key(key)] = convert_val(val) unless final?
    end

    def final?
      @final
    end

    def include?(key)
      @config.include?(convert_key(key))
    end
    alias :has? :include?
    alias :has_key? :include?

    def update!(other_hash)
      other_hash.each do |k,v|
        @config[convert_key(k)] = convert_val(v)
      end

      self
    end
    alias :merge! :update!

    def empty?; @config.empty?; end
    def size; @config.size; end
    def each(&block); @config.each(&block); end
    def each_value(&block); @config.each_values(&block); end
    def each_key(&block); @config.each_key(&block); end

    def delete(key)
      @config.delete(convert_key(key))
    end

    def symbolize_keys; @config.symbolize_keys; end
    def symbolize_keys!; raise "Not supported!"; end

    def keys; @config.keys; end
    def values; @config.values; end

    def pretty
      @config.inspect
    end

    protected

    def aliases
      if defined?(@aliases)
        @aliases
      else
        @aliases = { }
      end
    end

    def config_alias(key, *aliases)
      unless aliases.empty?
        aliases.each do |a|
          self.aliases[convert_key(a, true)] = key
        end
      end
    end

    def convert_val(val)
      if val.is_a?(Hash)
        # self.class.new(@casens, val)
        ConfigHelper.new(@casens, val)
      else
        val
      end
    end

    def convert_key(key, ignore_alias = false)
      ckey = nil
      if @casens
        ckey = key.to_s
      else
        ckey = key.to_s.downcase
      end

      unless ignore_alias
        aliases[ckey] || ckey
      else
        ckey
      end
    end

    def clone
      my_clone = PopoTools::ConfigHelper.new(@casens)
      @config.each do |key,val|
        if val.kind_of? self.class
          my_clone[key] = val.clone
        else
          my_clone[key] = val
        end
      end
      my_clone
    end
  end
end

