class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
  helper_method :current_user, :logged_in?

  def current_user
    @current_user = User.find_by_id(session[:user_id]) if logged_in?
  end

  def logged_in?
    session[:user_id]
  end
end
