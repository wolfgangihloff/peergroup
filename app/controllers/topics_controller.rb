class TopicsController < ApplicationController

  def new
    @topic = Supervision.find(params[:supervision_id]).topics.build
  end

end
