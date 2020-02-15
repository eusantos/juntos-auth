class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update, :destroy]
  before_action :authenticate, except: [:login, :update]

  include ActionController::HttpAuthentication::Token::ControllerMethods

  TOKEN = "meutoken"


  def login
    @user = User.find_by(login: params[:login])
    if !@user.nil?
      "compara a senha enviada com a senha que tenho gravada"
      se a saenha ta certa, então eu gero um token e salvo no banco,
      devolvo um json apenas com o token gerado
    else 
      render json: "usuario e/ou senha incorretos", status: :unprocessable_entity
  end

  # GET /users
  def index
    @users = User.all

    render json: @users, except: [:token, :token_exp, :password]
  end

  # GET /users/1
  def show
    render json: @user, except: [:token, :token_exp, :password]
  end

  # POST /users
  def create
    @user = User.new(user_params)

    if @user.save
      render json: @user, status: :created, except: [:token, :token_exp, :password], location: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  #Só permite atualizar o password
  # PATCH/PUT /users/1
  def update
    
    if @user.password == Digest::MD5.hexdigest(params[:password]) && @user.login == params[:login] 
      user.password = params[:new_password] 
      user.token = nil
    else
      render json: "usuario e/ou senha incorretos", status: :unprocessable_entity
    end
    
    if @user.update
      render json: @user, except: [:token, :token_exp, :password]
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def user_params
      params.require(:user).permit(:login, :password, :email, :token, :password_confirmation)
    end

    def user_params_update
      params.require(:user).permit(:login, :password, :new_password)
    end

    def authenticate

      confiro se o existe algum usuario com o token enviado, e se ele ainda é valido, se for, retorna true, se não não

      # authenticate_or_request_with_http_token do |token, option|
      #   ActiveSupport::SecurityUtils.secure_compare(
      #     ::Digest::SHA256.hexdigest(token),
      #     ::Digest::SHA256.hexdigest(TOKEN),
      #   )
      end
    end
end
