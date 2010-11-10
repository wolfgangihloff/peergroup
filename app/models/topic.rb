class Topic < ActiveRecord::Base
  validates_presence_of :supervision, :supervision_id
  validates_presence_of :author, :author_id

  belongs_to :supervision
  belongs_to :author, :class_name => "User"
end

