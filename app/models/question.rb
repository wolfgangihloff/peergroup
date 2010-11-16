class Question < ActiveRecord::Base

  validates_presence_of :user, :user_id
  validates_presence_of :content
  validates_presence_of :supervision, :supervision_id

  belongs_to :user
  belongs_to :supervision

  has_one :answer

  scope :unanswered, where('(SELECT count(*) FROM answers WHERE answers.question_id = questions.id) = 0')

end

