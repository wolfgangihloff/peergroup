class ApplicationController < ActionController::Base
  include FlashMessages
  include SessionsHelper

  protect_from_forgery

  before_filter :set_locale, :set_location, :setup_title

  protected

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def set_location
    is_sessions_controller = (controller_name == "sessions")
    is_new_user_action = (controller_name == "users" && action_name == "new")
    session[:return_to] = request.fullpath if request.get? && !is_sessions_controller && !is_new_user_action
  end

  def default_url_options
    {:locale => I18n.locale}
  end

  def setup_title
    @title = t("#{controller_name}.#{action_name}.title")
  end

  def self.require_supervision_state(*args)
    options = args.extract_options!
    filter_name = :"require_supervision_#{args.join("_or_")}_state"

    define_method filter_name do
      unless args.map(&:to_s).include?(@supervision.state)
        redirect_to supervision_path(@supervision)
        false
      end
    end

    before_filter filter_name, options
  end
end

