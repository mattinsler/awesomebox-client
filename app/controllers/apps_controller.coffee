_ = require 'underscore'
async = require 'async'
walkabout = require 'walkabout'
ApplicationController = Caboose.get('ApplicationController')

class App
  constructor: (opts) ->
    _(@).extend(opts)
    @is_local = @directory?
    @is_remote = @user?
    @is_running = false
  
  @from_dir: (path, callback) ->
    path = walkabout(path)
    try
      config = path.join('.awesomebox.json').require()
    catch err
      return callback(new Error('Could not find awesomebox configuration in ' + path.absolute_path))
    return callback(new Error('Not a valid awesomebox configuration')) unless config?.name?
    config.directory = path.absolute_path
    callback(null, new @(config))

class AppsController extends ApplicationController
  index: ->
    async.map (awesomebox.client_config.client_apps or []), (path, cb) ->
      App.from_dir path, (err, app) -> cb(null, app)
    , (err, apps) =>
      @respond_json(200, _(apps).compact())
