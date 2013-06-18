_ = require 'underscore'
fs = require 'fs'
async = require 'async'
walkabout = require 'walkabout'
App = require './app'
Properties = require './properties'
{EventEmitter} = require 'events'

class AwesomeboxConfig extends Properties
  constructor: (@config_file) ->
    super()
    @config_file = walkabout(@config_file)
    @_read_config()
    
    @on 'change', (changes, opts) =>
      @config_file.write_file_sync(JSON.stringify(@to_json())) if opts.write isnt false
  
  _read_config: ->
    try
      @set(JSON.parse(@config_file.read_file_sync()), write: false)
    catch err
      console.log 'AWESOMEBOX CONFIG LOAD ERROR'
      console.log err.stack
    
    # @watcher = fs.watch(@config_file.absolute_path, persistent: false)
    # @watcher.on 'error', (err) ->
    #   console.log 'WATCHER ERROR'
    #   console.log err.stack
    # @watcher.on 'change', ->
    #   console.log 'WATCHER CHANGE'
    #   console.log arguments


class AppRepository extends EventEmitter
  constructor: ->
    @config = new AwesomeboxConfig(process.env.HOME + '/.awesomebox')
    
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

module.exports = AppRepository
