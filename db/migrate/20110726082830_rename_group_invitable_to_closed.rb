class RenameGroupInvitableToClosed < ActiveRecord::Migration
  def self.up
    rename_column(:groups, :invitable, :closed)
  end

  def self.down
    rename_column(:groups, :closed, :invitable)
  end
end
