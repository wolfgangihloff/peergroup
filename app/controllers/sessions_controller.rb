class SessionsController < ApplicationController
  # NOTE
  # If this application ever uses "remember me" functionality, read
  # http://weblog.rubyonrails.org/2011/2/8/csrf-protection-bypass-in-ruby-on-rails

  def new
  end

  def create
    user = User.authenticate(params[:session][:email],
                             params[:session][:password])
    if user.nil?
      flash.now[:error] = "Invalid email/password combination."
      render 'new'
    else
      sign_in user
      redirect_back_or root_path
    end
  end

  def destroy
    sign_out
    redirect_to root_path
  end
end
