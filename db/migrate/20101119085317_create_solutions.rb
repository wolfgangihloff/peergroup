class CreateSolutions < ActiveRecord::Migration
  def self.up
    create_table :solutions do |t|
      t.integer  "supervision_id"
      t.integer  "user_id"
      t.text     "content"
      t.integer  "rating"

      t.timestamps
    end
  end

  def self.down
    drop_table :solutions
  end
end
