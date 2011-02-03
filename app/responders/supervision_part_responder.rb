class SupervisionPartResponder < ActionController::Responder
  def to_html
    if get? # show action
      if request.params[:partial]
        resource_class_name = resource.class.to_s.underscore
        render :partial => resource_class_name,
          :layout => false,
          :locals => { resource_class_name.to_sym => resource }
      end
    else # create action
      if has_errors?
        redirect_to options[:location], flash_message_hash("alert")
      else
        redirect_to options[:location], flash_message_hash("notice")
      end
    end
  end

  def to_json
    if !get?
      if has_errors?
        render :status => :unprocessable_entity,
          :json => { :flash => flash_message_hash("alert") }
      else
        render :status => :created,
          :json => { :flash => flash_message_hash("notice") }
      end
    end
  end

  protected

  def flash_message_hash(severity)
    if options[:no_flash]
      {}
    else
      { severity.to_sym => flash_message(severity) }
    end
  end

  def flash_message(severity)
    I18n.t("#{controller.controller_name}.#{controller.action_name}.#{severity}")
  end
end
