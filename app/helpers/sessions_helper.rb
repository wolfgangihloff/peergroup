module SessionsHelper
end
# module SessionsHelper
#   def sign_in(user)
#     user.remember_me!
#     cookies[:remember_token] = {
#       :value   => user.remember_token,
#       :expires => 20.years.from_now.utc
#     }
#     self.current_user = user
#   end
# 
#   def current_user=(user)
#     @current_user = user
#   end
# 
#   def current_user
#     @current_user ||= user_from_remember_token
#   end
# 
#   def user_from_remember_token
#     remember_token = cookies[:remember_token]
#     User.find_by_remember_token(remember_token) unless remember_token.nil?
#   end
# 
#   def signed_in?
#     !current_user.nil?
#   end
#   def sign_out
#     cookies.delete(:remember_token)
#     self.current_user = nil
#   end
#   def current_user?(user)
#     user == current_user
#   end
#   def deny_access
#     store_location
#     successful_flash("Please sign in to access this page.", :key => "flash.sign_in_request")
#     redirect_to signin_path
#   end
# 
#   def authenticate
#     deny_access unless signed_in?
#   end
# 
#   def store_location
#     session[:return_to] = request.fullpath
#   end
# 
#   def redirect_back_or(default)
#     redirect_to(session[:return_to] || default)
#     clear_return_to
#   end
# 
#   def clear_return_to
#     session[:return_to] = nil
#   end
# 
# end
