class CreateSolutionsFeedbacks < ActiveRecord::Migration
  def self.up
    create_table :solutions_feedbacks do |t|
      t.text     "content"
      t.integer  "supervision_id"
      t.integer  "user_id"

      t.timestamps
    end
  end

  def self.down
    drop_table :solutions_feedbacks
  end
end
