cot
===

Cot is a gem designed to help convert rest based resources into ruby objects.  Currently it only handles converting the responses into objects and doesn't deal with the requests themselves, there are plenty of gems for that out there.

### Example

```ruby
class NestedClass < Cot::Frame
  property :parent_id
  property :foo, from: :bar
end

class ExampleObject < Cot::Frame
  property :id
  property :name, :searchable => true
  property :company_name, :from => :companyName
  property :item do
    from :place
    value do |params|
      NestedClass.new params.merge parent_id: id
    end
  end
  enum :types do
    entry :first
    entry :third, value: 3
    entry :fourth
  end
  search_property :created_at, :from => :createdOn
end

class ExampleCollection < Cot::Collection
  def initialize(objects, options = {})
    super ExampleObject, objects, options
  end
end

thingy = ExampleObject.new(id: :my_id, name: 'awesome name', createdOn: Time.now, place: {bar: 'this is nested.foo'})
thingy.id # 5
thingy.name # awesome name
thingy.types.fourth # 4
thingy.item # NestedClass instance
thingy.item.foo # 'this is nested.foo'
thingy.created_at # what time it is now
thingy.defined\_properties # [:id, :name, :created_at]

collection = ExampleCollection.new [{ id: :my_id, name: 'awesome name', createdOn: Time.now }, { id: :my_id, name: 'awesome name', createdOn: Time.now }], { default_attributes: { default: :attribute }
collection.first.name # 'awesome name'
collection.first.default # :attribute
collection.exists? # Do all of the entries exist?
collection.update_members [{ id: 1, name: 'new awesome name', createdOn: Time.now }, { id: 2, name: 'new awesome name', createdOn: Time.now }]
collection.first.name # 'new awesome name'
```


### Details

Using cot is pretty simple. There are two main classes: Collection and Frame. Collections are basically big arrays that contain objects (presumably Frame objects). Collection provides some helper methods to manage the collection, but also delegates to Array, so each, map and all that good stuff are there as well. Frame allows you to declare how the object will convert a json payload into an object.

Frame provides some helpful methods:
- Class Methods
    - property
      - The first parameter is the name of the property and it is added as a method to the object.
      - You can pass additional options in two ways, first you can pass a hash of options to property and secondly you can pass a block to property.
      - There are three optional arguments, value, from and searchable.  
      - From indicates that the property has an alternate key in the incoming/outgoing data.  
      - Searchable adds the property to the search mappings.
      - Value takes a block and overwrites the value of the property to be the result of the block
        - This is useful for nested objects.
        - The block is executed as part of the instance of the object, so you have access to other properties.
        - The block takes one parameter, which is the value of the hash for that key (what the value would have been if there was no value block).
    - search\_property adds the parameter to the search mapping.  It takes an optional from argument which inidates the property has an alternate key in the incoming/outgoing data.
    - enum takes a name and a block
      - The block expects a series of entries to be declared
      - enum starts counting at 1 by default
      - Each entry will have the value of 1 higher than the previous by default
      - An optional value parameter can be passed which sets the entries value to that number. This lets you skip a numer, start higher or lower or even be non-sequential.
- Instance Methods
    - defined\_properties returns a list of the defined properties
    - properties\_mapping returns a hash containing all of the renamed properties.  The keys are the values of the from argument and the values are the property name.
    - inverted\_properties\_mapping returns an inverted hash containing all of the renamed properties.  This is the same as properties\_mapping but the property names are the keys and the froms are the values
    - search\_mappings returns a hash containing the search properties.  If a from was provided then that is the key otherwise the key and the value will be the property name.
    - inverted\_search\_mappings returns an inverted search\_mappings hash.
    - serializable\_hash returns hash with the correct keys to post back.  AKA, it reverts the keys to what the from arguments (if any) were.
    - to\_json returns a json encoded version of serializable\_hash.
    - valid? true if errors is empty
    - errors used to store any errors associated with the object

Collection provides the following methods:
- Initialization
  - You can pass options to the collection when you initialize
  - sub\_key: Uses the contents inside the sub\_key
  - default_attributes: Will add the keys/values to the object
- Instance Methods
  - The following methods collate the results from members
    - serializable\_hash
    - to\_json
    - errors (pulls into a hash with member.id as the key)
  - exists? returns true if *all* the members exist
  - changed? returns true if *any* of the members have changed
  - update\_members updates the members of the collection to based on the payload (this can add or remove members)
