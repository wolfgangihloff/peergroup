class Vote < ActiveRecord::Base
  belongs_to :user
  belongs_to :statement, :polymorphic => true

  validates_presence_of :user, :user_id
  validates_presence_of :statement, :statement_id
end
