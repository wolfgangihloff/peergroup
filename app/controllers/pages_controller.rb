class PagesController < ApplicationController
  def home
    @title = "Home"
    render :action => signed_in? ? 'home_member' : 'home_guest'
  end

  def contact
    @title = "Contact"
  end
  
  def about
    @title = "About"
  end

  def help
    @title = "Help"
  end


end
