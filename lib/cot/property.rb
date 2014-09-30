module Cot
  class Property
    attr_accessor :args
    def initialize(params = {})
      @args = params
    end

    def value(&block)
      return args[:value] unless block
      args[:value] = block
    end

    [:from, :searchable].each do |method_name|
      define_method method_name do |value = nil|
        return args[method_name] if value.nil?
        args[method_name] = value
      end
    end
  end
end
