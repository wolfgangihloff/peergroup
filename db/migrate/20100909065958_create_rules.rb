class CreateRules < ActiveRecord::Migration
  def self.up
    create_table :rules do |t|
      t.belongs_to :group

      t.string :name
      t.integer :position
      t.text :description
      t.integer :time_limit

      t.timestamps
    end
  end

  def self.down
    drop_table :rules
  end
end
