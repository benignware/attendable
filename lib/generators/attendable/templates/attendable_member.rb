class AttendableMember < ActiveRecord::Base
  belongs_to :attendable, polymorphic: true
  belongs_to :invitee, polymorphic: true
end