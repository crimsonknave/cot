module Cot
  class Collection < SimpleDelegator
    def initialize(klass, objects)
      @klass = klass
      initialize_objects(objects)

      super @objects
    end

    def serializable_hash
      @objects.map(&:serializable_hash)
    end

    def to_json
      serializable_hash.to_json
    end

    def exists?
      @objects.map(&:exists?).all?
    end

    def update_members(payload)
      # NOTE: replacing objects is lazy, but I don't want to deal with updating and such righ tnow
      initialize_objects(payload)
    end

    def changed?
      @objects.map(&:changed?).include? true
    end

    private

    def initialize_objects(objects)
      @objects = []
      @objects = objects.map do |payload|
        @klass.new payload
      end

      # Set the delegator methods to point to the new objects array
      __setobj__(@objects)
    end
  end
end
