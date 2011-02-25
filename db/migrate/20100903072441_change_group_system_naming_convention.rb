class ChangeGroupSystemNamingConvention < ActiveRecord::Migration
  def self.up
    rename_table :groups_users, :group_members

    change_table :groups do |t|
      t.belongs_to :founder
    end
  end

  def self.down
    rename_table :group_members, :groups_users

    change_table :groups do |t|
      t.remove :founder_id
    end
  end
end
