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

      if self.class.klass.nil?
        fail 'Collected class not set, please either pass a class to initialize or call collected_class'
      end
      # If you pass in different types of things here we can't be friends
      initialize_objects(@objects) unless @objects.first.instance_of? self.class.klass

      super @objects
    end

    def serializable_hash
      map(&:serializable_hash)
    end

    def to_json
      serializable_hash.to_json
    end

    def exists?
      map(&:exists?).all?
    end

    def errors
      Hash[reject(&:valid?).map { |x| [x.id, x.errors] }]
    end

    def update_members(payload)
      # NOTE: replacing objects is lazy, but I don't want to deal with updating and such right now
      initialize_objects(payload)
    end

    def changed?
      map(&:changed?).include? true
    end

    private

    def parse_params(params)
      until params.empty?
        item = params.shift
        if item.instance_of? Class
          self.class.klass = item
        elsif item.instance_of? Array
          @objects = item
        else
          options = item
        end
      end
      options ||= {}
      parse_options(options)
    end

    def parse_options(options)
      options = { sub_key: options } unless options.instance_of?(Hash)
      @options = options.with_indifferent_access
      @options[:default_attributes] = {} unless @options[:default_attributes]
      self.class.set_default_values
      @options.merge! self.class.options
    end

    def initialize_objects(objects)
      @objects = objects.map do |payload|
        payload = payload.fetch(@options[:sub_key], {}) if @options[:sub_key]
        self.class.klass.new @options[:default_attributes].merge(payload)
      end

      # Set the delegator methods to point to the new objects array
      __setobj__(@objects)
    end
  end
end
