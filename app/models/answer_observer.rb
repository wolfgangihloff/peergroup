class AnswerObserver < ActiveRecord::Observer
  def after_create(answer)
    supervision = answer.question.supervision
    if supervision.state == "topic_question" && supervision.all_next_step_votes? && supervision.all_answers?
      supervision.next_step!
    end
  end
end
