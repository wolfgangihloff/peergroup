module FlashMessages

  def t(key, options = {})
    key = key.to_s[0..0] == "." ? [controller_name, action_name].join('.') + key : key
    I18n.t(key, options)
  end

  def successful_flash(default, options = {})
    key = ".flash.success"
    options_with_default = {:default => default}.merge(options)
    flash[:notice] = t(key, options_with_default)
  end
end
