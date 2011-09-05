class RemoveRules < ActiveRecord::Migration
  def self.up
    drop_table :rules
    remove_column :chat_rooms, :current_rule_id
  end

  def self.down
    add_column :chat_rooms, :current_rule_id, :integer
    create_table "rules", :force => true do |t|
      t.integer  "group_id"
      t.string   "name"
      t.integer  "position"
      t.text     "description"
      t.integer  "time_limit"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
