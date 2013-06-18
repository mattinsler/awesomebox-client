crypto = require 'crypto'
{spawn} = require 'child_process'

open = require 'open'
walkabout = require 'walkabout'
Properties = require './properties'
AwesomeboxClient = require 'awesomebox.node'

AWESOMEBOX_PATH = walkabout('node_modules/awesomebox/bin/awesomebox').absolute_path

class App extends Properties
  constructor: (opts) ->
    super()
    
    if opts.user? and opts.name?
      @id = "#{opts.user}/#{opts.name}"
    else if opts.name?
      @id = "local/#{opts.name}"
    
    @set(opts)
    @set(
      id: @id
      is_local: @has('local_directory')
      is_remote: @has('user')
      local_running: false
    )
  
  @from_dir: (path) ->
    path = walkabout(path)
    try
      config = path.join('.awesomebox.json').require()
    catch err
      throw new Error('Could not find awesomebox configuration in ' + path.absolute_path)
    throw new Error('Not a valid awesomebox configuration') unless config?.name?
    config.local_directory = path.absolute_path
    new @(config)
  
  open_local: ->
    return unless @get('local_running') is true
    open 'http://localhost:' + @get('local_port')
  
  open_folder: ->
    open @get('local_directory')
  
  start_local: (callback) ->
    on_start = (err, port) =>
      @set(
        local_starting: false
        local_port: port
        local_running: true
      )
      callback?(null, port)
    
    if @get('local_starting')
      @once 'change:local_port', (port) ->
        callback?(null, port)
      return @proc
    
    if @get('local_running')
      callback?(null, @get('local_port'))
      return @proc
    
    @set(local_starting: true)
    @proc = awesomebox.spawn(@get('local_directory'), on_start)
    @proc.on 'close', =>
      @set(
        local_port: undefined
        local_running: false
      )
      delete @proc
    @proc
  
  stop_local: ->
    @proc?.kill()
  
  ship: ->
    return if @get('is_shipping')
    @set(is_shipping: true)
    
    push = (err, filename) =>
      return @set(is_shipping: false) if err?
      client = new AwesomeboxClient(api_key: Caboose.app.app_repo.config.get('api_key'))
      client.app(@get('name')).update filename, (err, data) ->
        walkabout(filename).unlink_sync()
        console.log arguments
        @set(is_shipping: false)
    
    packager = require 'awesomebox/lib/packager'
    deployment_file = walkabout().join('deploy-' + @get('name') + '-' + crypto.randomBytes(4).toString('hex') + '.tgz')
    packager.pack(@get('local_directory'), deployment_file.absolute_path, push)

module.exports = App
