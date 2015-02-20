module Cot
  class Collection < SimpleDelegator
    extend CollectionClassMethods

    # We take an array of params here and then parse them due to backwards compat crap
    # Collection can take 1-3 parameters and there are two cases when it gets two
    # 3: klass, objects, options
    # 2: klass, objects
    # 2: objects, options
    # 1: objects
    def initialize(*params)
      parse_params(params)

      # If you pass in different types of things here we can't be friends
      initialize_objects(@objects) unless @objects.first.is_a? self.class.klass

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
      Hash[@objects.reject(&:valid?).map { |x| [x.id, x.errors] }]
    end

    def update_members(payload)
      # NOTE: replacing objects is lazy, but I don't want to deal with updating and such right now
      initialize_objects(payload)
    end

    def changed?
      @objects.map(&:changed?).include? true
    end

    private

    def parse_params(params)
      until params.empty?
        item = params.shift
        if item.class == Class
          self.class.klass = item
        elsif item.class == Array
          @objects = item
        else
          options = item
        end
      end
      options ||= {}
      parse_options(options)
    end

    def parse_options(options)
      options = { sub_key: options } unless options.is_a?(Hash)
      @options = options.with_indifferent_access
      @options[:default_attributes] = {} unless @options[:default_attributes].is_a?(Hash)
      self.class.set_default_values
      @options.merge! self.class.options
    end

    def initialize_objects(objects)
      @objects = []
      @objects = objects.map do |payload|
        if @options[:sub_key]
          self.class.klass.new @options[:default_attributes].merge(payload.fetch(@options[:sub_key], {}))
        else
          self.class.klass.new @options[:default_attributes].merge(payload || {})
        end
      end

      # Set the delegator methods to point to the new objects array
      __setobj__(@objects)
    end
  end
end
