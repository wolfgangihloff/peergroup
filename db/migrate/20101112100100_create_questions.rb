class CreateQuestions < ActiveRecord::Migration
  def self.up
    create_table :questions do |t|
      t.text :question
      t.belongs_to :user
      t.belongs_to :supervision

      t.timestamps
    end
  end

  def self.down
    drop_table :questions
  end
end

