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

Show a list of attendees on the event's page and provide a link to update the user's rsvp status:
```
# app/views/events/show.html.haml

<% @event.attendees.each do |user| %>
  <p>User #<%= user.id.to_s %></p>
<% end %>

<%= link_to(@event.is_attending?(current_user) ? "Refuse" : "Attend", rsvp_event_path(@event, {rsvp_status: @event.is_attending?(current_user) ? :declined : :attending})) %>
```


Invitation Example
------------------

The attendable-plugin also let's you invite users to a specific attendable instance - even if they're not registered yet.

This is achieved by an invitation_token which is generated with the member in conjuction with an invitation_key that serves as identity.

In this example, only invited users may attend or refuse the event.

Extend the above example as follows... 

Add the mail gem to your Gemfile and run bundle install
```
gem "mail"
```

Configure mail to work in development
```
# config/environments/development.rb
MyApplication::Application.configure do
  ...
  # mailer settings
  config.mailer_sender = "xxx@xxx.com"  
  config.action_mailer.perform_deliveries = true
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.logger = nil
  config.action_mailer.default_url_options = { :host => "localhost:3000" }
  config.action_mailer.smtp_settings = {
    :address => "smtp.xxx.com",
    :port => "25",
    :domain => "xxx.com",
    :user_name => "xxx@xxx.com",
    :password => "xxx",
    :authentication => :plain 
  }
  ...
end
```

Generate the event mailer
```
rails g mailer EventMailer
```

Setup the invitation method
```
# app/mailers/event_mailer.rb
class EventMailer < ActionMailer::Base
  default from: "from@example.com"
  
  def invitation(email, event, member, inviter)
    @event = event
    @inviter = inviter
    @attend_url = rsvp_event_path(@event, invitation_token: member.invitation_token, rsvp_status: :attending, only_path: false)
    mail(to: email, subject: 'Event invitation')
  end
  
end
```

Setup the invitation text email
```
# app/views/event_mailer/invitation.text.erb
Welcome friend,

You were invited to an event.
To attend the event, please click this link: <%= @attend_url %>

Thanks for joining and have a great day!
```

Setup the invitation html email
```
# app/views/event_mailer/invitation.html.erb
<!DOCTYPE html>
<html>
  <head>
    <meta content='text/html; charset=UTF-8' http-equiv='Content-Type' />
  </head>
  <body>
    <h1>Welcome friend,</h1>
    <p>
      You were invited to an event.
    </p>
    <p>
      To attend the event, please click this link: <%= @attend_url %>
    </p>
    <p>Thanks for joining and have a great day!</p>
  </body>
</html>
```


Add 'invite' to event routes
```
# config/routes.rb
resources :events do
  member do
    get 'rsvp'
    post 'invite'
  end
end
```

Add 'invite' action to controller and modify rsvp action to accept invitation_token.
```
# app/controllers/event_controller.rb
class EventsController < ApplicationController
  
  before_action :set_event, only: [:show, :edit, :update, :destroy, :rsvp, :invite]
 
  ...
  
  def rsvp
    # find current_user member
    if params[:invitation_token]
      # find member by invitation_token
      event_member = @event.accept_invitation(params[:invitation_token], current_user)
      if (!event_member)
        # invalid token
      end
    else
      # find by id
      event_member = @event.event_members.where(["invitee_id = ?", current_user.id])[0]
    end
    if event_member
      event_member.rsvp_status = params[:rsvp_status]
    else
      # user is not permitted to rsvp the event
    end
    if event_member.save
      redirect_to @event, notice: 'Status was successfully updated.'
    else
      redirect_to @event, notice: 'Status could not be saved.'
    end
  end
  
  def invite
    params[:invitations][:emails].split(",").each do |email|
      # find user-member by email or use email as invitation_key  
      if member = @event.invite(User.find_by_email(email) || email)
        # send invitation email
        EventMailer.invitation(email, @event, member, current_user).deliver
      end
    end
    respond_to do |format|
      format.html { redirect_to @event, notice: 'Invitations have been successfully sent.' }
      format.json { head :no_content }
    end
  end
  
end
```

Provide a dialog for sending invitations using haml and a bootstrap3-modal:
```
.modal.fade#send-event-invitations{tabindex:-1, role:"dialog", aria:{labelledby:"send-event-invitations-label", hidden:"true"}}
  .modal-dialog
    = simple_form_for :invitations, url: invite_event_path(@event), :html=> { class: 'modal-content' } do |f|
      .modal-header
        %button.close{type:"button", data: {dismiss:"modal"}, aria:{hidden:"true"}}='&times'.html_safe
        %h4.modal-title#send-event-invitations-label='Send invitations'
      .modal-body
        = f.input :emails
      .modal-footer
        %button.btn.btn-default{type:"button", data:{dismiss:"modal"}}='Close'
        = f.submit 'Send', class: 'btn btn-primary'
        
%button.btn.btn-primary{data: {toggle:"modal", target:"#send-event-invitations"}}='Send invitations'
```

   