class CreateAttendableMembers < ActiveRecord::Migration
  def self.up
    create_table :attendable_members do |t|
      t.string :status
      t.references :attendable, polymorphic: true
      t.references :user, polymorphic: true
      t.timestamps
    end
  end

  def self.down
    drop_table :attendable_members
  end
end