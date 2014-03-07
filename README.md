acts_as_attendable
==========

The attendable-plugin let's you add members to a Group model and easily build rsvp actions

Usage
-----

```
rails generate attendable:install
```


```
# app/models/event.rb
class Event < ActiveRecord::Base
  
  include Attendable
  is_attendable by: :users, as: :event_members
    
end
```


