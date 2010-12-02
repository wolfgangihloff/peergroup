class Answer < ActiveRecord::Base

  belongs_to :question
  belongs_to :user

  delegate :supervision, :to => :question

  validates_presence_of :question, :question_id
  validates_presence_of :user, :user_id
  validates_presence_of :content

end

