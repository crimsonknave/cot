cot
===

Cot is a gem designed to help convert rest based resources into ruby objects.  Currently it only handles converting the responses into objects and doesn't deal with the requests themselves, there are plenty of gems for that out there.

### Usage

Using cot is pretty simple, include it in your project and then have your class inherit from Cot::Frame.

Frame provides some helpful methods:
- Class Methods
..- property
....- Property 
..- search\_property
- Instance Methods
..- foo

```ruby
class ExampleObject < Cot::Frame
end
```
