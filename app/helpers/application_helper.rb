# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  # Return a title on a per-page basis.

  def gravatar(*args)
    raw super
  end

  def title
    base_title = "Peer Supervision Groups"
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
    js_code = "document.pgs = {controller: '#{controller.class}'};"
    js_code += "document.pgs.supervision_step = '#{@supervision.state}';" if @supervision
    javascript_tag js_code
  end

end
