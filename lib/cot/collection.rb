module Cot
  class Collection < SimpleDelegator
    def initialize(klass, objects, options = {})
      options = { sub_key: options } unless options.is_a?(Hash)
      @options = options.with_indifferent_access
      @options[:default_attributes] = {} unless @options[:default_attributes].is_a?(Hash)
      @klass = klass
      @objects = objects

      # If you pass in different types of things here we can't be friends
      initialize_objects(objects) unless objects.first.is_a? klass

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

    def errors
      Hash[@objects.reject { |x| x.valid? }.map { |x| [x.id, x.errors] }]
    end

    def update_members(payload)
      # NOTE: replacing objects is lazy, but I don't want to deal with updating and such right now
      initialize_objects(payload)
    end

    def changed?
      @objects.map(&:changed?).include? true
    end

    private

    def initialize_objects(objects)
      @objects = []
      @objects = objects.map do |payload|
        if @options[:sub_key]
          @klass.new @options[:default_attributes].merge(payload.fetch(@options[:sub_key], {}))
        else
          @klass.new @options[:default_attributes].merge(payload || {})
        end
      end

      # Set the delegator methods to point to the new objects array
      __setobj__(@objects)
    end
  end
end
