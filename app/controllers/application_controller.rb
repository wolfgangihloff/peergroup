# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include FlashMessages

  helper :all # include all helpers, all the time
  include SessionsHelper
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password

  protected

  def require_parent_group
    @group = Group.find(params[:group_id])
  end
end
