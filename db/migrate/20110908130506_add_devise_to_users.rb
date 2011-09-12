class AddDeviseToUsers < ActiveRecord::Migration
  def self.up
    ## remove old authentication system
    remove_column :users, :salt
    remove_column :users, :remember_token
    remove_column :users, :encrypted_password
    ## add devise
    change_table(:users) do |t|
      t.string :encrypted_password, :null => false, :default => "", :limit => 128
      t.recoverable
      t.rememberable
    end

    add_index :users, :reset_password_token, :unique => true
  end

  def self.down
    remove_column :users, :database_authenticatable
    remove_column :users, :recoverable
    remove_column :users, :rememberable
    remove_index :users, :reset_password_token

    add_column :users, :email, :string
    add_column :users, :encrypted_password, :string
    add_column :users, :remember_token, :string
    add_column :users, :salt, :string
  end
end
