class Topic < ActiveRecord::Base
  belongs_to :user
  belongs_to :supervision, :touch => true

  has_many :votes, :as => :statement, :dependent => :destroy

  validates_presence_of :user
  validates_presence_of :supervision

  attr_accessible :content

  after_create do |topic|
    supervision = topic.supervision.post_topic
  end
end

