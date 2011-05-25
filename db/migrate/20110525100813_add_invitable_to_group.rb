class AddInvitableToGroup < ActiveRecord::Migration
  def self.up
    add_column :groups, :invitable, :boolean, :default => false
    Group.reset_column_information
    Group.update_all({:invitable => false}, {:invitable => nil})
  end

  def self.down
    remove_column :groups, :invitable
  end
end
