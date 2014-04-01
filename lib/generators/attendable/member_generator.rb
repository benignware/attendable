require 'active_support/core_ext/module/introspection'
require 'rails/generators/base'
require 'rails/generators/generated_attribute'

module Attendable
  module Generators
    class MemberGenerator < ::Rails::Generators::NamedBase
      
      argument :attributes, type: :array, default: [], banner: "field[:type][:index] field[:type][:index]"
      
      
      include Rails::Generators::Migration
      source_root File.expand_path('../templates', __FILE__)
      
      def self.next_migration_number(path)
        Time.now.utc.strftime("%Y%m%d%H%M%S")
      end
      
      def create_migrations
        migration_template 'create_attendable_members.erb', "db/migrate/create_#{name.tableize}.rb", {name: self.name, attributes: self.attributes}
        template 'attendable_member.erb', "app/models/#{name.tableize.singularize}.rb", {name: self.name, attributes: self.attributes}
      end
      
      
    end
  end
end