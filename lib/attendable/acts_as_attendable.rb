module Attendable
  module ActsAsAttendable
    extend ActiveSupport::Concern
 
    included do
    end
 
    module ClassMethods
      
      def acts_as_attendable(options = {})
        # your code will go here
        puts '************  ACTS AS EXEC'
        
        include Attendable::ActsAsAttendable::LocalInstanceMethods
        
      end

    end
    
    module LocalInstanceMethods
      
      
    end
      
  end
end
 
ActiveRecord::Base.send :include, Attendable::ActsAsAttendable