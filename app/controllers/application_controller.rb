require 'flash_messages'

class ApplicationController < ActionController::Base
  include FlashMessages
  include SessionsHelper
  include SupervisionPathsHelper

  protect_from_forgery

  protected

  def require_parent_group
    @group = Group.find(params[:group_id])
  end

  def require_parent_supervision
    @supervision = Supervision.find(params[:supervision_id])
  end

  def redirect_to_correct_supervision_step
    controller_step = self.class.to_s.gsub("Controller", "").singularize.underscore

    if @supervision.state != controller_step
      redirect_to supervision_step_path(@supervision)
      false
    end
  end

  def self.require_supervision_step(*steps)
    filter_name = :"require_supervision_#{steps.join("_or_")}_step"

    define_method filter_name do
      unless steps.map(&:to_s).include?(@supervision.state)
        redirect_to supervision_step_path(@supervision)
        false
      end
    end

    before_filter filter_name
  end
end

