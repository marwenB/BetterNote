class SessionsController < ApplicationController
  before_action :require_signed_out!, only: [:new, :create]
  before_action :require_signed_in!, only: [:destroy]

  def create
    @user = User.find_by_credentials(
      params[:user][:email],
      params[:user][:password])
    if @user
      log_in(@user)
      redirect_to user_url(@user)
    else
      flash.now[:errors] = ["Invalid credentials.  Please try again."]
      render :new
    end
  end

  def new
    @user = User.new
    render :new
  end

  def destroy
    logout_current_user
    redirect_to new_session_url
  end
end