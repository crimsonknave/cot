module Cot
  class Enum
    attr_accessor :num, :used
    def initialize
      @used = {}
      @num = 1
    end

    def entry(name, options = {})
      value = options[:value] || num
      if used.key? value
        fail "#{name} tried to set value #{value}, which is already used by #{used[value]}. Enum values are unique."
      end

      self.class.__send__ :define_method, name do
        value
      end

      @num = value + 1
      used[value] = name
    end

    def [](key)
      public_send key
    end
  end
end
