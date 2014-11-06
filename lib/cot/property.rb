module Cot
  class Property
    attr_accessor :args
    def initialize(params = {})
      @args = params
    end

    [:missing, :value].each do |method_name|
      define_method method_name do |&block|
        return args[method_name] unless block
        args[method_name] = block
      end
    end

    [:from, :searchable].each do |method_name|
      define_method method_name do |value = nil|
        return args[method_name] if value.nil?
        args[method_name] = value
      end
    end
  end
end
