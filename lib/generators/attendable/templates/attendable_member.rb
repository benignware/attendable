class AttendableMember < ActiveRecord::Base
  belongs_to :attendable, polymorphic: true
  belongs_to :invitee, polymorphic: true
  
  before_create :generate_token

  protected

  def generate_token
    self.activation_token = loop do
      random_token = SecureRandom.urlsafe_base64(nil, false)
      break random_token unless AttendableMember.exists?(activation_token: random_token)
    end
  end
  
end