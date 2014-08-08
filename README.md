cot
===

Cot is a gem designed to help convert rest based resources into ruby objects.  Currently it only handles converting the responses into objects and doesn't deal with the requests themselves, there are plenty of gems for that out there.

### Usage

Using cot is pretty simple. There are two main classes: Collection and Frame. Collections are basically big arrays that contain objects (presumably Frame objects). Collection provides some helper methods to manage the collection, but also delegates to Array, so each, map and all that good stuff are there as well. Frame allows you to declare how the object will convert a json payload into an object.

Frame provides some helpful methods:
- Class Methods
    - property adds the first parameter as an accessor on the object.  There are two optional arguments, from and searchable.  From indicates that the property has an alternate key in the incoming/outgoing data.  Searchable adds the property to the search mappings.
    - search\_property adds the parameter to the search mapping.  It takes an optional from argument which inidates the property has an alternate key in the incoming/outgoing data.
    - enum *NOT SUPPORTED* If you'd like to see this let me know. Also let me know what you'd want it to look like.
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
- Instance Methods
  - The following methods collate the results from members
    - serializable\_hash
    - to\_json
    - errors (pulls into a hash with member.id as the key)
  - exists? returns true if *all* the members exist
  - changed? returns true if *any* of the members have changed
  - update\_members updates the members of the collection to based on the payload (this can add or remove members)

```ruby
class ExampleObject < Cot::Frame
  property :id
  property :name, :searchable => true
  property :company_name, :from => :companyName
  search_property :created_at, :from => :createdOn
end

class ExampleCollection < Cot::Collection
  def initialize(params)
    super ExampleObject, params
  end
end

thingy = ExampleObject.new(id: :my_id, name: 'awesome name', createdOn: Time.now)
thingy.id # 5
thingy.name # awesome name
thingy.created_at # what time it is now
thingy.defined\_properties # [:id, :name, :created_at]

collection = ExampleCollection.new [{ id: :my_id, name: 'awesome name', createdOn: Time.now }, { id: :my_id, name: 'awesome name', createdOn: Time.now }]
collection.first.name # 'awesome name'
collection.exists? # Do all of the entries exist?
collection.update_members [{ id: 1, name: 'new awesome name', createdOn: Time.now }, { id: 2, name: 'new awesome name', createdOn: Time.now }]
collection.first.name # 'new awesome name'
```
