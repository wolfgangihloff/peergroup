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
end
