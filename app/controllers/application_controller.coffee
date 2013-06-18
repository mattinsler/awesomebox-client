crypto = require 'crypto'
AwesomeboxClient = require 'awesomebox.node'

add_gravatar_hash = (user) ->
  return user unless user?
  hash = crypto.createHash('md5')
  hash.update(user.email.toLowerCase())
  user.gravatar_hash = hash.digest('hex')
  user

class ApplicationController extends Controller
  index: ->
    client = new AwesomeboxClient(Caboose.app.awesomebox.client_config)
    client.user.get (err, user) =>
      @bootstrap_data = {
        user: add_gravatar_hash(user)
        config: {}
      }
      @render()
  
  login: ->
    client = new AwesomeboxClient(@body)
    client.user.get (err, user) =>
      if err?
        return @respond_json(err.status_code, error: err.body) if err.status_code?
        return @repond_with(err)
      
      config = awesomebox.client_config
      config.api_key = user.api_key
      awesomebox.client_config = config
      user = add_gravatar_hash(user)
      Caboose.app.faye.publish('/change/user', type: 'user', changes: {user: user})
      # Caboose.app.socket.send(user: user)
      
      @respond_with(user)
  
  logout: ->
    config = awesomebox.client_config
    delete config.api_key
    awesomebox.client_config = config
    
    Caboose.app.faye.publish('/change/user', type: 'user', changes: {user: null})
    # Caboose.app.socket.send(user: null)
    @respond_with('ok')
