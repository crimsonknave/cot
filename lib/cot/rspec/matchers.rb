RSpec::Matchers.define :set_search_property do |field|
  match do |base|
    if @from
      base.search_mappings[field] == @from
    else
      base.search_mappings[field] == field
    end
  end

  def from(from)
    @from = from
    self
  end
end
RSpec::Matchers.define :set_property do |field|
  match do |base|
    @tests = {}
    @tests[:attr_methods] = base.attr_methods.include?(field.to_sym)
    if @from
      @tests[:mappings] =  base.mappings[@from.to_sym] == field
    end
    if @searchable
      key = @from ? @from : field
      @tests[:searchable] = base.search_mappings[field] == key
    end
    example = base.new
    @tests[:reader] = example.respond_to?(field)
    @tests[:accessor] = example.respond_to?("#{field}=")
    @tests[:dirty] = example.respond_to?("#{field}_changed?")
    @tests.values.all?
  end

  def from(from)
    @from = from
    self
  end
  def searchable
    @searchable = true
    self
  end

  description do
    from_string = @from ? "from #{@from}" : ""
    search_string = @searchable ? "to be searchable" : ""
    "should set property #{field} #{from_string} #{search_string}"
  end

  failure_message_for_should do
    failed = @tests.select{|k,v| !v}.keys
    "Expected the property #{field} to be set, but the following attributes weren't set correctly #{failed}"
  end

end

