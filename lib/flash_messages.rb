module FlashMessages

  def t(key, options = {})
    if overwritten_scope = options.delete(:overwritten_scope)
      options[:scope] = overwritten_scope
    else
      key = key.to_s[0] == "." ? [controller_name, action_name].join('.') + key : key
    end
    I18n.t(key, options)
  end

  def flash_message(type, flash_type, default, options)
    key = if key_from_options = options.delete(:key)
      options[:overwritten_scope] = options.delete(:scope) || ""
      key_from_options
    else
      ".flash.#{type}"
    end
    options_with_default = {:default => default}.merge(options)
    flash[flash_type] = t(key, options_with_default)
  end

  def successful_flash(default, options = {})
    flash_message :successful, :notice, default, options
  end

  def error_flash(default, options = {})
    flash_message :error, :error, default, options
  end
end
