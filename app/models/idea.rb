class Idea < ActiveRecord::Base
  validates_presence_of :user, :user_id
  validates_presence_of :content
  validates_presence_of :supervision, :supervision_id

  belongs_to :user
  belongs_to :supervision
end

