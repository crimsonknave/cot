module Cot
  class Frame
    attr_accessor :errors

    extend FrameClassMethods

    include ActiveModel::Dirty

    def initialize(payload = nil)
      @errors = {}

      @data = convert_keys payload

      add_value_blocks

      add_missing_blocks
    end

    def exists?
      public_send self.class.primary_key
    end

    def defined_properties
      self.class.attr_methods || []
    end

    def properties_mapping
      self.class.mappings
    end

    def inverted_properties_mapping
      self.class.inverted_mappings ||= properties_mapping.invert
    end

    def search_mappings
      self.class.search_mappings
    end

    def inverted_search_mappings
      self.class.inverted_search_mappings ||= search_mappings.invert
    end

    def [](key)
      @data[convert_key key]
    end

    def []=(key, value)
      if self.class.value_blocks[key]
        block = self.class.value_blocks[key]
        value = instance_exec(value, &block)
      end
      @data[key] = value
    end

    def valid?
      errors.empty?
    end

    def to_json
      serializable_hash.to_json
    end

    def serializable_hash(options = {})
      attrs = {}
      properties_list = defined_properties
      properties_list &= Array(options[:only]).map(&:to_sym) if options[:only]
      properties_list -= Array(options[:except]).map(&:to_sym)
      properties_list.each do |m|
        attrs[inverted_properties_mapping.fetch(m, m)] = self[m]
      end
      attrs
    end

    private

    def add_missing_blocks
      defined_properties.each do |prop|
        if self[prop].nil? && self.class.missing_blocks[prop]
          block = self.class.missing_blocks[prop]
          self[prop] = instance_exec(&block)
        end
      end
    end

    def add_value_blocks
      @data.each do |k, v|
        if self.class.value_blocks[k]
          block = self.class.value_blocks[k]
          @data[k] = instance_exec(v, &block)
        end
      end
    end

    def convert_key(key)
      key = key.to_sym
      properties_mapping.fetch(key, key)
    end

    def convert_keys(hash)
      return {} unless hash
      {}.tap do |ret|
        hash.each_pair { |k, v| ret[convert_key k] = v }
      end
    end
  end
end
