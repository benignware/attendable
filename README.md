attendable
==========

The attendable-plugin let's you add members to a Group model and easily build rsvp actions

Usage
-----

Create an example model
```
rails g scaffold Event title:string date:date
```

Generate your member model
```
rails g attendable:member EventMember
```

You may also add custom attributes, for example:
```
rails g attendable:member EventMember role:string
```

Don't forget to run migrate after creating your models:
```
rake db:migrate
```

Now let your main model acts as attendable:
```
# app/models/event.rb
class Event < ActiveRecord::Base
  acts_as_attendable :event_members by: :users
end
```
This will add a has_many-association named 'event_members' to your model.
 
Use the 'by'-option to specify your invitee model by its symbolized plural name. The invitee class defaults to 'User'.

Methods
-------
Besides the member association, calling acts_as_attendable generates the following methods on your model object: 

<table>
  <tr>
    <th>Name</th>
    <th>Description</th>
    <th>Return</th>
  </tr>
  <tr>
    <td>is_member?(invitee)</td>
    <td>Returns true if the specified invitee is a member of the attendable instance</td>
    <td>Boolean</td>
  </tr>
  <tr>
    <td>is_attending?(invitee)</td>
    <td>Returns true if the specified invitee is attending</td>
    <td>Boolean</td>
  </tr>
  <tr>
    <td>has_declined?(invitee)</td>
    <td>Returns true if the specified invitee has declined</td>
    <td>Boolean</td>
  </tr>
  <tr>
    <td>attendees</td>
    <td>Returns a list of all attending invitees</td>
    <td>Array</td>
  </tr>
  <tr>
    <td>invite(invitee)</td>
    <td>Invite user to the attendable instance</td>
    <td>Array</td>
  </tr>
  <tr>
    <td>accept_invitation(invitation_token, invitee)</td>
    <td>Accept the invitation for the specified invitee</td>
    <td>Array</td>
  </tr>
</table>
