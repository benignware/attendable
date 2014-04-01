Attendable
==========

The attendable-plugin let's you add members to a model and easily setup rsvp actions

Usage
-----

Install the attendable-plugin by adding it to your Gemfile:
```
gem 'attendable', github: 'rexblack/attendable'
```

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
  acts_as_attendable :event_members, by: :users
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
    <td>Invite user to the attendable instance. Returns the corresponding member object</td>
    <td>Object</td>
  </tr>
  <tr>
    <td>accept_invitation(invitation_token, invitee)</td>
    <td>Accept the invitation for the specified invitee. Returns the corresponding member object</td>
    <td>Array</td>
  </tr>
</table>


Basic Example
-------------
In the following example, we'll build a simple rsvp-action where any user can attend to an event. 

Generate models
```
rails g scaffold Event title:string date:date
rails g attendable:member EventMember
rake db:migrate
```

Setup routes
```
# config/routes.rb
resources :events do
  member do
    get 'rsvp'
  end
end
```

Make the model attendable:
```
# app/models/event.rb
class Event < ActiveRecord::Base
  acts_as_attendable :event_members, by: :users
end
```

Setup controller actions
```
# app/controllers/event_controller.rb
class EventsController < ApplicationController
  
  before_action :set_event, only: [:show, :edit, :update, :destroy, :rsvp]
  
  ...
  
  def create
    @event = Event.new(event_params)
    # automatically add the creator of the event as an attending member
    @event.event_members.build({invitee: current_user, rsvp_status: :attending})
  end
  
  ...
  
  def rsvp
    # find current_user member
    event_member = @event.event_members.where(["invitee_id = ?", current_user.id])[0]
    if event_member
      event_member.rsvp_status = params[:rsvp_status]
    else
      # no member, so create one
      event_member = @event.event_members.build({invitee: current_user, rsvp_status: :attending})
    end
    if event_member.save
      redirect_to @event, notice: 'Status was successfully updated.'
    else
      redirect_to @event, notice: 'Status could not be saved.'
    end
    
  end
  
end
```

Show a list of attendees on the event's page and provide the user with a link to update rsvp status:
```
# app/views/events/show.html.haml

<% @event.attendees.each do |user| %>
  <p>User #<%= user.id.to_s %></p>
<% end %>

<%= link_to(@event.is_attending?(current_user) ? "Refuse" : "Attend", rsvp_event_path(@event, {rsvp_status: @event.is_attending?(current_user) ? :declined : :attending})) %>
```