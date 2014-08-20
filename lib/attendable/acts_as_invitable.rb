module Attendable
  
  module ActsAsInvitable
    
    extend ActiveSupport::Concern
   
    included do
    end
   
    module ClassMethods
      
      def acts_as_invitable(name, options = {})
        
        class_name = options[:class_name] || name.to_s.classify 
        
        attendable_class_name = options[:to]
        table_name = class_name.tableize
        has_many name, as: :invitable, dependent: :destroy, class_name: class_name
        has_many attendable_class_name.tableize.to_sym, ->{where "#{table_name}.rsvp_status = 'attending'"}, through: name, source: :attendable, source_type: attendable_class_name
        
        clazz = class_name.constantize
        
        # instance methods 
        define_method "is_member?" do |attendable| 
          puts 'is member? ' + attendable.to_s
          puts 'clazz: ' + clazz.to_s
          clazz.where(invitee: self, attendable: attendable).count > 0
        end
      
      end
  
    end
    
    
      
  end
end  
ActiveRecord::Base.send :include, Attendable::ActsAsInvitable
