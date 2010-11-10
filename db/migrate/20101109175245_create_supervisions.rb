class CreateSupervisions < ActiveRecord::Migration
  def self.up
    create_table :supervisions do |t|
      t.belongs_to :group
      t.string :state

      t.timestamps
    end
  end

  def self.down
    drop_table :supervisions
  end
end
