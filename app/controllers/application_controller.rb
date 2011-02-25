require 'flash_messages'

class ApplicationController < ActionController::Base
  include FlashMessages
  include SessionsHelper

  protect_from_forgery

  before_filter :setup_title

  protected

  def setup_title
    @title = t("#{controller_name}.#{action_name}.title")
  end

  def require_parent_group
    @group = Group.find(params[:group_id])
  end

  def require_parent_supervision
    @supervision = Supervision.find(params[:supervision_id])
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

