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
          puts '**** ACCEPT INVITATION: ' + invitee.to_s + " ----> " + invitee.email.to_s
          if (invitee)
            puts '**** ACCEPT INVITATION USER: ' + invitee.email.to_s + " --- " + self.is_member?(invitee).to_s
            if (!self.is_member?(invitee))
              puts '**** ACCEPT INVITATION TOKEN: ' + invitation_token.to_s
              token_member = clazz.where(invitation_token: invitation_token, attendable: self)[0]
              puts '**** ACCEPT INVITATION TOKEN MEMBER: ' + token_member.to_s + " ---- " + token_member.invitee.to_s
              if token_member
                if token_member.invitee.nil?
                  token_member.invitee = invitee
                  if !token_member.save
                    # error while saving
                  end
                elsif token_member.invitee != invitee
                  puts '**** MEMBER USER IS NOT INVITEE'
                  return nil
                end
                puts '**** RETURN MEMBER'
                return token_member
              end
              return nil
            else
              puts '**** GET MEMBER BY INVITEE '
              return clazz.where(invitee: invitee, attendable: self)[0]
            end
          end
        end
      end
  
    end
    
    
      
  end
end  
ActiveRecord::Base.send :include, Attendable::ActsAsAttendable
