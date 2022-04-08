class SessionsController < ApplicationController
  def login; end

  def create
    @user = User.find_by(username: params[:username])

    ## authenticate user credentials
    if @user && @user.authenticate(params[:password])
      # set session and redirect on success
      session[:user_id] = @user.id
      redirect_to documents_url
    else
      # error message on fail
      message = 'Something went wrong! Make sure your username and password are correct.'
      redirect_to login_url, notice: message
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to login_url
  end
end
