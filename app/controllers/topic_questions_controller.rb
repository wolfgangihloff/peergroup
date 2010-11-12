class TopicQuestionsController < ApplicationController

  before_filter :require_parent_supervision

  def new
  end

end
