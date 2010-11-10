class Topic < ActiveRecord::Base
  validates_presence_of :supervision, :supervision_id

  belongs_to :supervision
end
