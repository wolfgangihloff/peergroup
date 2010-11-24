class UsersController < ApplicationController
  before_filter :authenticate, :except => [:show, :new, :create]
  before_filter :correct_user, :only => [:edit, :update]
  before_filter :admin_user,   :only => :destroy

  def show
    @user = User.find(params[:id])
    @title = CGI.escapeHTML(@user.name)
  end

  def new
    redirect_to(root_path) unless current_user?(@user)
    @user = User.new
    @title = "Sign up"
  end

  def create
    redirect_to(root_path) unless current_user?(@user)
    @user = User.new(params[:user])
    if params[:user]["passcode"] != "Pat0ng0"
      flash[:error] = "Wrong Passcode"
      @title = "Sign up"
      @user.password = ""
      @user.password_confirmation = ""
      render 'new'
    elsif @user.save && params[:user]["passcode"] == "Pat0ng0"
      sign_in @user
      flash[:success] = "Welcome to the Peer Supervision Groups!"
      redirect_to @user
    else
      @title = "Sign up"
      @user.password = ""
      @user.password_confirmation = ""
      render 'new'
    end
  end

  def edit
    @title = "Edit user"
  end

  def index
    @title = "All Users"
    @users = User.paginate(:page => params[:page])
  end

  def update
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated."
      redirect_to @user
    else
      @title = "Edit user"
      render 'edit'
    end
  end

  def destroy
    # This should prevent users from deleteing themselves, the test is missing for this
    unless @user === User.find(params[:id]).destroy
      flash[:success] = "User destroyed."
      redirect_to users_path
    end
  end

  def following
    @title = "Following"
    @user = User.find(params[:id])
    @users = @user.following.paginate(:page => params[:page])
    render 'show_follow'
  end

  def followers
    @title = "Followers"
    @user = User.find(params[:id])
    @users = @user.followers.paginate(:page => params[:page])
    render 'show_follow'
  end

  private
  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_path) unless current_user?(@user)
  end

  def admin_user
    redirect_to(root_path) unless current_user.admin?
  end
end
