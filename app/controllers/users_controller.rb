class UsersController < ApplicationController
  before_action :set_user, except: [:index, :new, :create, :friend_requests]

  def index
    @users = User.all
  end

  def show
    @status = Status.new
  end

  def new
    @user = User.new
  end

  def edit
  end

  def create
    @user = User.new(user_params)
    @user.password = user_params[:password]
    respond_to do |format|
      if @user.save
        session[:user_id] = @user.id
        format.html { redirect_to @user, notice: 'User was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  def update
    respond_to do |format|
      if @user.update(user_params)
        user.id = session[:user_id]
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @user.destroy
    reset_session
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def remove_friendship
    current_user.remove_friendship(@user)
    redirect_to user_path
  end

  def send_friend_request
    current_user.send_friend_request(@user)
    redirect_to user_path
  end

  def accept_friend_request
    current_user.accept_friend_request(@user)
    redirect_to user_path
  end

  def friend_requests
    if logged_in?
      current_user.outgoing_friend_requests
      current_user.incoming_friend_requests
    else
      redirect_to root_path
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :password)
  end
end
