class AttendableMember < ActiveRecord::Base
  belongs_to :attendable, polymorphic: true
  belongs_to :user, polymorphic: true
end