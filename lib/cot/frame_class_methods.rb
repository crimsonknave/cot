module Cot
  module FrameClassMethods
    attr_accessor :attr_methods,
                  :inverted_mappings,
                  :inverted_search_mappings,
                  :search_mappings,
                  :value_blocks,
                  :missing_blocks,
                  :mappings

    def search_property(name, args = {})
      @search_mappings ||= {}

      key = args[:from] ? args[:from] : name
      @search_mappings[name] = key
    end

    def enum(name, &block)
      obj = Enum.new
      obj.instance_eval(&block)
      define_singleton_method name do
        obj
      end
      define_method name do
        obj
      end
    end

    def property(name, args = {}, &block)
      set_default_values
      prop = Property.new args
      prop.instance_eval(&block) if block

      set_blocks(name, prop)
      set_mappings(name, prop)

      define_property_methods name
    end

    private

    def set_blocks(name, prop)
      @value_blocks[name] = prop.value if prop.value
      @missing_blocks[name] = prop.missing if prop.missing
    end

    def set_mappings(name, prop)
      key = prop.from
      @mappings[key.to_sym] = name if key
      @search_mappings[name] = key ? key : name if prop.searchable
      attr_methods << name.to_sym
    end

    # Can't seem to get an intialize in for the class, so we need to set these
    # before we do stuff for property
    def set_default_values
      @mappings ||= {}
      @attr_methods ||= []
      @search_mappings ||= {}
      @value_blocks ||= {}
      @missing_blocks ||= {}
    end

    def define_property_methods(name)
      define_method name do
        self[name]
      end

      define_method "#{name}=" do |value|
        send("#{name}_will_change!") unless value == self[name]
        self[name] = value
      end
      define_attribute_method name
    end
  end
end
