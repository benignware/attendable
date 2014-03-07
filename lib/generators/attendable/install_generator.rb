module Attendable
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      
      include Rails::Generators::Migration
      source_root File.expand_path('../templates', __FILE__)
      
      def self.next_migration_number(path)
        Time.now.utc.strftime("%Y%m%d%H%M%S")
      end
      
      def create_migrations
        puts 'install attendable'
        migration_template 'create_attendable_members.rb', "db/migrate/create_attendable_members.rb"
        template 'attendable.rb', "app/models/attendable.rb"
        template 'attendable_member.rb', "app/models/attendable_member.rb"
      end
      
    end
  end
end