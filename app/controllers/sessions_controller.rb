class SessionsController < ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.find_by(email: params[:email])
    if @user && @user.password == params[:password]
      session[:user_id] = @user.id
      redirect_to root_path
    else
      redirect_to '/login'
    end
  end

  def destroy
    reset_session
    session.destroy
    respond_to do |format|
      format.html { redirect_to root_path, notice: 'Log out successful.' }
      format.json { head :no_content }
    end
  end
end
