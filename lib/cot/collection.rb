module Cot
  class Collection < SimpleDelegator
    def initialize(klass, objects)
      @objects = {}
      objects.each  do |payload|
        obj = klass.new payload
        @objects[obj.id] = obj
      end


      super @objects
    end
  end
end
