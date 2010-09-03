class RemoveAllGroups < ActiveRecord::Migration
  def self.up
    Group.destroy_all
  end

  def self.down
  end
end
