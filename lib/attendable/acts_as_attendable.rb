module Attendable
  module ActsAsAttendable
    
    extend ActiveSupport::Concern
   
    included do
    end
   
    module ClassMethods
      
      def acts_as_attendable(options = {})
  
        attendee_class_name = options[:by].present? ? options[:by].to_s.classify.constantize : "User"
        association_name = options[:as] || :attendable_members
        has_many association_name, as: :attendable, dependent: :destroy, class_name: "AttendableMember"
        has_many :attendees, -> { where(attendable_members: {status: :attending}) }, through: association_name, source: :invitee, source_type: attendee_class_name
        
        include ActsAsAttendable::LocalInstanceMethods
      
      end
  
    end
    
    module LocalInstanceMethods
      
      def is_member?(user)
        AttendableMember.where(invitee: user, attendable: self).count > 0
      end
      
      def is_invited?(user)
        AttendableMember.where(invitee: user, attendable: self).count > 0
      end
      
      def is_attending?(user)
        AttendableMember.where(invitee: user, attendable: self, status: 'attending').count > 0
      end
      
      def has_declined?(user)
        AttendableMember.where(invitee: user, attendable: self, status: 'declined').count > 0
      end
      
      def invite(user)
        if user.is_a?(String)
          invitation_key = user
          is_invited = AttendableMember.where(invitation_key: invitation_key, attendable: self).count > 0
          if !is_invited
            return AttendableMember.create(attendable: self, invitation_key: invitation_key, status: 'pending')
          end
        elsif !is_member?(user)
          AttendableMember.create(attendable: self, invitation_key: invitation_key, status: 'pending')
        end
      end
      
      def accept_invitation(invitation_token, invitee)
        if (!self.is_member?(invitee))
          token_member = AttendableMember.where(activation_token: invitation_token, attendable: self)[0]
          if token_member && token_member.invitee.nil?
            token_member.invitee = invitee
            token_member.save
            return token_member
          else
            return nil
          end
        else
          return AttendableMember.where(invitee: invitee, attendable: self)[0]
        end
      end
      
    end
      
  end
end  
ActiveRecord::Base.send :include, Attendable::ActsAsAttendable
