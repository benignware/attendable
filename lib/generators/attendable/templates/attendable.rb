module Attendable
  def is_attendable(options)
    attendee_class_name = options[:by].present? ? options[:by].to_s.classify.constantize : "User"
    association_name = options[:as] || :attendable_members
    has_many association_name, as: :attendable, dependent: :destroy, class_name: "AttendableMember"
    has_many :attendees, -> { where(attendable_members: {status: :attending}) }, through: association_name, source: :user, source_type: attendee_class_name
    include InstanceMethods
    
    
    def is_member?(user)
      AttendableMember.where(user: user, attendable: self).count > 0
    end
    
    def is_invited?(user)
      AttendableMember.where(user: user, attendable: self, status: 'pending').count > 0
    end
    
    def is_attending?(user)
      AttendableMember.where(user: user, attendable: self, status: 'attending').count > 0
    end
    
  end
  module InstanceMethods
    def attendable?
      true
    end
  end
end
ActiveRecord::Base.extend Attendable