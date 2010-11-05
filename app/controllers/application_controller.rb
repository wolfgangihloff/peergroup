require 'flash_messages'

class ApplicationController < ActionController::Base
  include FlashMessages
  include SessionsHelper

  protect_from_forgery

  protected

  def require_parent_group
    @group = Group.find(params[:group_id])
  end
end
