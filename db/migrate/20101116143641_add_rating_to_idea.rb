class AddRatingToIdea < ActiveRecord::Migration
  def self.up
    change_table :ideas do |t|
      t.integer :rating
    end
  end

  def self.down
    change_table :ideas do |t|
      t.remove :rating
    end
  end
end
