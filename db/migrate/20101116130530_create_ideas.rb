class CreateIdeas < ActiveRecord::Migration
  def self.up
    create_table :ideas do |t|
      t.belongs_to :supervision
      t.belongs_to :user
      t.text :content

      t.timestamps
    end
  end

  def self.down
    drop_table :ideas
  end
end
