class UsersController < ApplicationController
  before_action :authenticate, except: [:login, :create]

  include ActionController::HttpAuthentication::Token::ControllerMethods

  def login
    @user = User.find_by(login: params[:login])
    if !@user.nil?
      if @user.password == Digest::MD5.hexdigest(params[:password])
        @user.token = Digest::SHA1.hexdigest([Time.now, rand].join)
        @user.token_exp = DateTime.now + 3.day
        @user.save
        render json: @user, only: [:token, :token_exp]
      else
        render json: "{\"Erro\": \"usuario e/ou senha incorretos\"}", status: :unprocessable_entity
      end
    else 
      render json: "{\"Erro\": \"usuario e/ou senha incorretos\"}", status: :unprocessable_entity
    end
  end

  # GET /users
  def listar
    @users = User.all
    render json: @users, except: [:token, :token_exp, :password]
  end

  # GET /users/1
  def busca
    render json: @user, except: [:token, :token_exp, :password]
  end

  # POST /users
  def create
    @user = User.new(user_params)
    @user.password = Digest::MD5.hexdigest(@user.password)
    if @user.save
      render json: @user, status: :created, except: [:token, :token_exp, :password], location: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  #Só permite atualizar o password
  # PATCH/PUT /users/1
  def mudasenha
    if(@user.password == Digest::MD5.hexdigest(params[:password]) && @user.login == params[:login]) 
      @user.password = Digest::MD5.hexdigest(params[:new_password])
      @user.token = nil
      if @user.save
        render json: @user, except: [:token, :token_exp, :password]
      else
        render json: @user.errors, status: :unprocessable_entity
      end
    else
      render json: "{\"Erro\": \"usuario e/ou senha incorretos\"}", status: :unprocessable_entity
      return
    end
  end

  # DELETE /users/1
  def remover
    if !@user.nil?
      if @user.destroy
        render json: "{\"Erro\": \"Usuario removido com sucesso\"}"
      end
    else
      render json: "{\"Erro\": \"Sem permissão para remover o usuário\"}"
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    def set_user_token
      authenticate_or_request_with_http_token do |token, option|
        @user = User.find_by(token: token)
      end
      #@user = User.find_by(token: params[:token])
    end

    # Only allow a trusted parameter "white list" through.
    def user_params
      params.require(:user).permit(:login, :password, :email, :token, :password_confirmation)
    end

    def user_params_update
      params.require(:user).permit(:login, :password, :new_password)
    end

    def authenticate
      #confiro se o existe algum usuario com o token enviado, e se ele ainda é valido, se fo, retorna true, se não false
      set_user_token
      if @user.nil?
        return false
      end
      if (@user.token_exp.nil? || @user.token_exp < DateTime.now)
        return false
      else
        authenticate_or_request_with_http_token do |token, option|
          ActiveSupport::SecurityUtils.secure_compare(
            ::Digest::SHA256.hexdigest(token),
            ::Digest::SHA256.hexdigest(@user.token),
          )
        end
      end
    end
end
