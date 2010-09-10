class AddCurrentRuleColumnToChatRoom < ActiveRecord::Migration
  def self.up
    change_table :chat_rooms do |t|
      t.belongs_to :current_rule
    end
  end

  def self.down
    change_table :chat_rooms do |t|
      t.remove :current_rule_id
    end
  end
end
