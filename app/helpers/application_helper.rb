# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
# Return a title on a per-page basis.
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
   RDiscount.new(text).to_html
 end
end
