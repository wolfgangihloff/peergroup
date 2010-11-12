class ChangeTopicAuthorToUser < ActiveRecord::Migration
  def self.up
    change_table :topics do |t|
      t.remove :author_id
      t.belongs_to :user
    end
  end

  def self.down
    change_table :topics do |t|
      t.remove :user_id
      t.belongs_to :author
    end
  end
end
