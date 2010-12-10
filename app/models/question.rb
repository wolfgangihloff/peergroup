class Question < ActiveRecord::Base
  belongs_to :user
  belongs_to :supervision, :touch => true

  has_one :answer, :dependent => :destroy

  validates_presence_of :user
  validates_presence_of :supervision
  validates_presence_of :content

  attr_accessible :content

  scope :unanswered, where('(SELECT count(*) FROM answers WHERE answers.question_id = questions.id) = 0')
end

