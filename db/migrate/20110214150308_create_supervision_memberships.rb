class CreateSupervisionMemberships < ActiveRecord::Migration
  def self.up
    create_table :supervision_memberships do |t|
      t.integer :supervision_id
      t.integer :user_id
    end

    add_index :supervision_memberships, [:supervision_id]
    add_index :supervision_memberships, [:user_id]
  end

  def self.down
    drop_table :supervision_memberships
  end
end
