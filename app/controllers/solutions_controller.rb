class SolutionsController < ApplicationController

  before_filter :require_parent_supervision

  def index
  end
end

