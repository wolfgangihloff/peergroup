require 'supervision_part'

class Question < ActiveRecord::Base
  include SupervisionPart

  validates_presence_of :content

  has_one :answer

  scope :unanswered, where('(SELECT count(*) FROM answers WHERE answers.question_id = questions.id) = 0')

end

