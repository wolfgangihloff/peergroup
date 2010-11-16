class IdeasController < ApplicationController

  before_filter :require_parent_supervision

  def index
  end

end
