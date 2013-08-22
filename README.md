cot
===

Cot is a gem designed to help convert rest based resources into ruby objects.  Currently it only handles converting the responses into objects and doesn't deal with the requests themselves, there are plenty of gems for that out there.

### Usage

Using cot is pretty simple, include it in your project and then have your class inherit from Cot::Frame.

Frame provides some helpful methods:
- Class Methods
    - property adds the first parameter as an accessor on the object.  There are two optional arguments, from and searchable.  From indicates that the property has an alternate key in the incoming/outgoing data.  Searchable adds the property to the search mappings.
    - search\_property adds the parameter to the search mapping.  It takes an optional from argument which inidates the property has an alternate key in the incoming/outgoing data.
- Instance Methods
    - defined\_properties returns a list of the defined properties
    - properties\_mapping returns a hash containing all of the renamed properties.  The keys are the values of the from argument and the values are the property name.
    - inverted\_properties\_mapping returns an inverted hash containing all of the renamed properties.  This is the same as properties\_mapping but the property names are the keys and the froms are the values
    - search\_mappings returns a hash containing the search properties.  If a from was provided then that is the key otherwise the key and the value will be the property name.
    - inverted\_search\_mappings returns an inverted search\_mappings hash.
    - serializable\_hash returns hash with the correct keys to post back.  AKA, it reverts the keys to what the from arguments (if any) were.
    - to\_json returns a json encoded version of serializable\_hash.

```ruby
class ExampleObject < Cot::Frame
  property :id
  property :name, :searchable => true
  property :company_name, :from => :companyName
  search_property :created_at, :from => :createdOn
end

thingy = ExampleObject.new(id: :my_id, name: 'awesome name', createdOn: Time.now)
thingy.id # 5
thingy.name # awesome name
thingy.created_at # what time it is now
thingy.defined\_properties # [:id, :name, :created_at]
```
