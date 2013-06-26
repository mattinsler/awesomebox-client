{EventEmitter} = require 'events'
fs = require 'fs'

_ = require 'underscore'
async = require 'async'
walkabout = require 'walkabout'

App = require './app'
AwesomeboxConfig = require './awesomebox_config'

Caboose.app.awesomebox_config = new AwesomeboxConfig(process.env.HOME + '/.awesomebox')

class AppRepository extends EventEmitter
  constructor: ->
    @config = Caboose.app.awesomebox_config
    
    @apps = []
    @apps_by_id = {}
    for path in (@config.get('client_apps') ? [])
      try
        a = App.from_dir(path)
        if a?
          @_bind_to_app(a)
          @apps.push(a)
          @apps_by_id[a.id] = a
      catch err
  
  _bind_to_app: (app) ->
    app.on 'change', (changes) =>
      @emit('apps:change', app, changes)
  
  get: (app_id) ->
    @apps_by_id[app_id]
  
  add: (app) ->
    apps = @config.get('client_apps') ? []
    apps.push(app.get('local_directory'))
    @config.set(client_apps: apps)
    @config._write_config()
    
    @_bind_to_app(app)
    @apps.push(app)
    @apps_by_id[app.id] = app
    app
  
  remove: (app) ->
    

module.exports = AppRepository
