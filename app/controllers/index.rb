get '/' do

  erb :index
end


get '/sign_in' do
  redirect request_token.authorize_url #### 2 - 4
end


get '/sign_out' do
  session.clear
  redirect '/'
end


get '/auth' do #### 5
  # the `request_token` method is defined in `app/helpers/oauth.rb`
  @access_token = request_token.get_access_token(:oauth_verifier => params[:oauth_verifier]) #### 6 & 7
  p '$' * 200
  # our request token is only valid until we use it to get an access token, so let's delete it from our session
  session.delete(:request_token)
  p @access_token.secret
  @user = User.find_or_create_by_username(@access_token.params[:screen_name])
  @user.oauth_token = @access_token.token
  @user.oauth_secret = @access_token.secret
  @user.save
  session[:user_id] = @user.id

  redirect '/'
end


post '/tweet_confirm' do
  @twitter_user = Twitter::Client.new(
    :oauth_token => current_user.oauth_token,
    :oauth_token_secret => current_user.oauth_secret) 
  @twitter_user.update(params[:tweet_input])

  redirect '/'
end