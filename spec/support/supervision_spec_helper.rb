module SupervisionSpecHelper
  def active_state
    find(".supervision_statusbar .current_step span").text
  end

  def within_question_with_text(text)
    within(:xpath, xpath_for_question(text)) do
      yield
    end
  end

  def within_answer_for_question_with_text(text)
    within(:xpath, xpath_for_answer(text)) do
      yield
    end
  end

  def xpath_for_question(text)
    "//div[@class='question']/div[@class='content']/p[. ='#{text}']/../.."
  end

  def xpath_for_answer(text)
    "//div[@class='question']/div[@class='content']/p[. ='#{text}']/../div[@class='answer']/p"    
  end
end