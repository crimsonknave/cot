module CollectionClassMethods
  attr_accessor :klass, :options

  def collected_class(klass)
    @klass = klass
  end

  [:sub_key, :default_attributes].each do |method_name|
    define_method method_name do |value|
      set_default_values
      @options[method_name] = value
    end
  end

  def set_default_values
    @options ||= {}
  end
end
