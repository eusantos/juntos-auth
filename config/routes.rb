Rails.application.routes.draw do
  resources :users
  post '/cadastra' => 'users#create'
  post '/login' => 'users#login'
  get '/busca' => 'users#busca'
  get '/listar' => 'users#listar'
  post '/mudasenha' => 'users#mudasenha'
  delete '/remover' => 'users#remover'
end
