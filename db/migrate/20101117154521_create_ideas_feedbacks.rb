class CreateIdeasFeedbacks < ActiveRecord::Migration
  def self.up
    create_table :ideas_feedbacks do |t|
      t.text :content
      t.belongs_to :supervision
      t.belongs_to :user

      t.timestamps
    end
  end

  def self.down
    drop_table :ideas_feedbacks
  end
end

