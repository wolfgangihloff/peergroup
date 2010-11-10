class TopicBelongsToAuthor < ActiveRecord::Migration
  def self.up
    change_table :topics do |t|
      t.belongs_to :author
    end
  end

  def self.down
    change_table :topics do |t|
      t.remove :author_id
    end
  end
end
