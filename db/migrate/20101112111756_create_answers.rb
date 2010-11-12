class CreateAnswers < ActiveRecord::Migration
  def self.up
    create_table :answers do |t|
      t.text :answer
      t.belongs_to :question
      t.belongs_to :user

      t.timestamps
    end
  end

  def self.down
    drop_table :answers
  end
end
