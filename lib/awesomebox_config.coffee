walkabout = require 'walkabout'
Properties = require './properties'

class AwesomeboxConfig extends Properties
  constructor: (@config_file) ->
    super()
    @config_file = walkabout(@config_file)
    @_read_config()
    
    @on 'change', (changes, opts) =>
      @_write_config() if opts.write isnt false
  
  _write_config: ->
    @config_file.write_file_sync(JSON.stringify(@to_json()))
  
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

module.exports = AwesomeboxConfig
