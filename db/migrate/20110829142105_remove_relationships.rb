class RemoveRelationships < ActiveRecord::Migration
  def self.up
    drop_table :relationships
  end

  def self.down
    create_table "relationships", :force => true do |t|
      t.integer  "follower_id"
      t.integer  "followed_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
