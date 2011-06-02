# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  def switch_locale_url(locale)
    actions = Hash.new {|h,method| method}
    actions.merge!("update" => "edit", "create" => "new")

    url_for(:action => actions[action_name], :locale => locale)
  end

  # Return a title on a per-page basis.

  def gravatar(*args)
    raw super
  end

  def title
    base_title = t(".base_title", :default => "peergroup")
    if @title.nil?
      base_title
    else
      "#{base_title} | #{h(@title)}"
    end
  end

  def logo
    logo = image_tag("logo.png", :alt => "Sample App", :class => "round")
  end

  def markdown(text)
    raw RDiscount.new(text).to_html
  end

  def javascript_meta_information
    pgs = {
      :controller => controller.class.to_s
    }
    pgs[:supervision_step] = @supervision.state if @supervision
    pgs[:currentUser] = current_user.id if current_user

    javascript_tag "document.pgs = #{pgs.to_json};"
  end

  def id_for_body
    [controller_name, action_name].join "_"
  end
end
