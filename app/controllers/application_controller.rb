require 'flash_messages'

class ApplicationController < ActionController::Base
  include FlashMessages
  include SessionsHelper

  protect_from_forgery

  protected

  def require_parent_group
    @group = Group.find(params[:group_id])
  end

  def require_parent_supervision
    @supervision = Supervision.find(params[:supervision_id])
  end

  def self.require_supervision_step(*steps)
    filter_name = :"require_supervision_#{steps.join("_or_")}_step"

    define_method filter_name do
      unless steps.map(&:to_s).include?(@supervision.state)
        redirect_to supervision_path(@supervision)
        false
      end
    end

    before_filter filter_name
  end
end

