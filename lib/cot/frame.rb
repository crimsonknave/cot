module Cot
  class Frame
    class << self
      attr_accessor :mappings, :inverted_mappings, :attr_methods, :search_mappings, :inverted_search_mappings
    end
    include ActiveModel::Dirty

    def initialize(payload = {})
      @data = convert_keys payload
    end

    def exists?
      # TODO: Have this key off a defined primary key instead of defaulting to id
      id
    end

    def defined_properties
      self.class.attr_methods
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

    def self.search_property(name, args = {})
      @search_mappings ||= {}

      key = args[:from] ? args[:from] : name
      @search_mappings[name] = key
    end

    # TODO: Create an enum declaration that will automagically map a symbol to
    # another value (such as an int) so that the user of the library doesn't need
    # to know what number scheduled status is (for example)
    def self.enum(_name, _args = {})
      fail 'enum is not yet implemented'
    end

    def self.property(name, args = {})
      @mappings ||= {}
      @attr_methods ||= []
      @search_mappings ||= {}
      key = args[:from]
      @mappings[key.to_sym] = name if key
      @search_mappings[name] = key ? key : name if args[:searchable]
      attr_methods << name.to_sym

      define_method name do
        self[name]
      end

      define_method "#{name}=" do |value|
        send("#{name}_will_change!") unless value == self[name]
        self[name] = value
      end
      define_attribute_method name
    end

    def [](key)
      @data[convert_key key]
    end

    def []=(key, value)
      @data[convert_key key] = value
    end

    def to_json
      serializable_hash.to_json
    end

    def serializable_hash
      attrs = {}
      defined_properties.each do |m|
        attrs[inverted_properties_mapping.fetch(m, m)] = self[m]
      end
      attrs
    end

    private

    def convert_key(key)
      key = key.to_sym
      properties_mapping.fetch(key, key).to_sym
    end

    def convert_keys(hash)
      return {} unless hash
      {}.tap do |ret|
        hash.each_pair { |k, v| ret[convert_key k] = v }
      end
    end
  end
end
