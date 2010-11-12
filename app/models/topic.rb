class Topic < ActiveRecord::Base
  validates_presence_of :supervision, :supervision_id
  validates_presence_of :user, :user_id

  belongs_to :supervision
  belongs_to :user

  has_many :votes, :as => :statement
end

