class AddTopicToSupervision < ActiveRecord::Migration
  def self.up
    change_table :supervisions do |t|
      t.belongs_to :topic
    end
  end

  def self.down
    change_table :supervisions do |t|
      t.remove :topic
    end
  end
end

