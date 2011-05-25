class AddStateAndEmailToMembership < ActiveRecord::Migration
  def self.up
    add_column :memberships, :state, :string
    add_column :memberships, :email, :string
    Membership.reset_column_information
    Membership.update_all({:state => "active"}, {:state => nil})
    Membership.find_each(:conditions => {:email => nil}) do |membership|
      membership.email = membership.user.email
      membership.save
    end
  end

  def self.down
    remove_column :memberships, :email
    remove_column :memberships, :state
  end
end
