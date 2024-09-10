require "logger"
require "bcrypt"
require "uri"

class SessionsController < ApplicationController
  get "/login" do
    @user = User.new
    haml :login
  end

  post "/login" do
    login_service = LoginService.new(
      params[:username],
      params[:password],
      settings.jwt_secret[:secret]
    )
    result = login_service.call

    if result[:success]
      response.set_cookie(
        "jwt",
        value: result[:token],
        expires: Time.now + 14 * 86400
      )

      redirect to "/"
    else
      status result[:status]
      @user = User.new(username: params[:username])
      flash[:error] = result[:message]
      haml :login
    end
  end

  get "/logout" do
    response.delete_cookie("jwt")
    redirect "/"
  end

  get "/unauthenticated" do
    redirect "/login"
  end
end
