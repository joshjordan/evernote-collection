puts 'Development routes enabled'

#Lifted from https://dev.evernote.com/doc/start/ruby.php
def client
  @client ||= EvernoteOAuth::Client.new(
    consumer_key: ENV['EVERNOTE_CONSUMER_KEY'],
    consumer_secret: ENV['EVERNOTE_CONSUMER_SECRET'],
    sandbox: false
  )
end

get '/authorize' do
  callback_url = request.url.chomp('authorize').concat('callback')
  $TOKEN = client.request_token(oauth_callback: callback_url)
  redirect $TOKEN.authorize_url
end

get '/callback' do
  halt({ error: 'Content owner did not authorize the temporary credentials' }) unless params['oauth_verifier']
  begin
    access_token = $TOKEN.get_access_token(oauth_verifier: params['oauth_verifier'])
    { success: true, output: `heroku config:set OAUTH_TOKEN=#{access_token.params[:oauth_token]}` }.to_json
  rescue => e
    { error: "Error extracting access token: #{e.message}" }.to_json
  end
end
