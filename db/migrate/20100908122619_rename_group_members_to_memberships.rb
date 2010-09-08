class RenameGroupMembersToMemberships < ActiveRecord::Migration
  def self.up
    rename_table :group_members, :memberships
  end

  def self.down
    rename_table :memberships, :group_members
  end
end
