class PagesController < ApplicationController
  def home
    @title = t(".title", :default => "Home")
    render :action => signed_in? ? 'home_member' : 'home_guest'
  end

  def contact
    @title = t(".title", :default => "Contact")
  end
  
  def about
    @title = t(".title", :default => "About")
  end

  def help
    @title = t(".title", :default => "Help")
  end
end

