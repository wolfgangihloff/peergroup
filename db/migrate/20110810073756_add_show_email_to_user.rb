class AddShowEmailToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :show_email, :boolean, {:null => false, :default => false}
  end

  def self.down
    remove_column :users, :show_email
  end
end
