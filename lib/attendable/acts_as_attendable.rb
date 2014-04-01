module Attendable
  
  module ActsAsAttendable
    
    extend ActiveSupport::Concern
   
    included do
    end
   
    module ClassMethods
      
      def acts_as_attendable(name, options = {})
        
        class_name = options[:class_name] || name.to_s.classify 
        attendee_class_name = options[:by].present? ? options[:by].to_s.classify : "User"
        table_name = class_name.tableize
        has_many name, as: :attendable, dependent: :destroy, class_name: class_name
        has_many :attendees, conditions: "#{table_name}.rsvp_status = 'attending'", through: name, source: :invitee, source_type: attendee_class_name
        clazz = class_name.constantize
        
        # instance methods 
        define_method "is_member?" do |user| 
          puts 'is member? ' + user.to_s
          puts 'clazz: ' + clazz.to_s
          clazz.where(invitee: user, attendable: self).count > 0
        end
      
        define_method "is_invited?" do |user| 
          clazz.where(invitee: user, attendable: self).count > 0
        end
        
        define_method "is_attending?" do |user| 
          clazz.where(invitee: user, attendable: self, rsvp_status: 'attending').count > 0
        end
        
        define_method "has_declined?" do |user| 
          clazz.where(invitee: user, attendable: self, rsvp_status: 'declined').count > 0
        end
        
        define_method "invite" do |user| 
          if user.is_a?(String)
            invitation_key = user
            is_invited = clazz.where(invitation_key: invitation_key, attendable: self).count > 0
            if !is_invited
              return clazz.create(attendable: self, invitation_key: invitation_key, rsvp_status: 'pending')
            end
          elsif !is_member?(user)
            clazz.create(attendable: self, invitation_key: invitation_key, rsvp_status: 'pending')
          end
        end
        
        define_method "accept_invitation" do |invitation_token, invitee| 
          if (invitation_token && invitee)
            if !is_member?(invitee)
              # only process invitation token if invitee is not already set
              token_member = clazz.where(invitation_token: invitation_token, attendable: self)[0]
              if token_member
                if token_member.invitee.nil?
                  # create member invitee
                  token_member.invitee = invitee
                  if !token_member.save
                    # error while saving
                  end
                elsif token_member.invitee != invitee
                  # member's invitee is not the current invitee
                  return nil
                end
                return token_member
              end
            else
              # if a member for invitee already exists, return the current invitee's member
              token_member = clazz.find_by_invitee(invitee)
              puts "-----> MEMBER EXISTS FIND BY INVITEE (current user)" + token_member.to_s
              return token_member
            end
          end
        end
      end
  
    end
    
    
      
  end
end  
ActiveRecord::Base.send :include, Attendable::ActsAsAttendable
