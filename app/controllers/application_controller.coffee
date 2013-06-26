User = Caboose.path.lib.join('user').require()
AwesomeboxClient = require 'awesomebox.node'

class ApplicationController extends Controller
  index: ->
    client = new AwesomeboxClient(Caboose.app.awesomebox.client_config)
    client.user.get (err, user) =>
      @bootstrap_data = {
        config: {}
      }
      @bootstrap_data.user = new User(user) if user?
      @render()
