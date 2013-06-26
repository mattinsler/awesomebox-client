crypto = require 'crypto'
{spawn} = require 'child_process'

open = require 'open'
async = require 'async'
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
    
    @__defineGetter__ 'client', ->
      api_key = Caboose.app.awesomebox_config.get('api_key')
      return null unless api_key?
      new AwesomeboxClient(api_key: api_key)
    
    @__defineGetter__ 'app_client', ->
      @client?.app(@get('name'))
  
  @from_dir: (path) ->
    path = walkabout(path)
    try
      config = path.join('.awesomebox.json').require()
    catch err
      throw new Error('Could not find awesomebox configuration in ' + path.absolute_path)
    throw new Error('Not a valid awesomebox configuration') unless config?.name?
    config.local_directory = path.absolute_path
    new @(config)
  
  @create_from_template: (opts, callback) ->
    opts.target.mkdirp()
    opts.target.join('.awesomebox.json').write_file_sync(JSON.stringify(
      name: opts.target.filename
    ))
    
    template_path = opts.template.absolute_path
    opts.template.ls_sync(recursive: true).forEach (file) ->
      fragment = file.absolute_path.slice(template_path.length + 1)
      return if fragment is 'template.json'
      
      to_file = opts.target.join(fragment)
      if file.is_directory_sync()
        to_file.mkdir_sync()
      else
        file.copy_sync(to_file)
    
    callback(null, @from_dir(opts.target.absolute_path))
  
  open_local: (opts, callback) ->
    return callback?() unless @get('local_running') is true
    open 'http://localhost:' + @get('local_port')
    callback?()
  
  open_folder: (opts, callback) ->
    open @get('local_directory')
    callback?()
  
  start_local: (opts, callback) ->
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
  
  stop_local: (opts, callback) ->
    @proc?.kill()
    callback?()
  
  ship: (opts, callback) ->
    return if @get('is_shipping')
    @set(is_shipping: true)
    
    if opts.log_channel?
      logger = Caboose.app.bayeux.getClient().publish.bind(Caboose.app.bayeux.getClient(), opts.log_channel)
    else
      logger = ->
    
    deployment_file = walkabout().join('deploy-' + @get('name') + '-' + crypto.randomBytes(4).toString('hex') + '.tgz')
    
    create_app = (cb) =>
      logger(status: 'Creating app ' + @get('name') + '...')
      @client.apps.create @get('name'), (err, data) =>
        return cb(err) if err?
        @set(data) if data?
        
        config_file = walkabout(@get('local_directory')).join('.awesomebox.json')
        config = config_file.require()
        config.user ?= @get('user')
        config_file.write_file_sync(JSON.stringify(config, null, 2))
        
        cb()
    
    create_package = (cb) =>
      logger(status: 'Packaging...')
      packager = require 'awesomebox/lib/packager'
      packager.pack(@get('local_directory'), deployment_file.absolute_path, cb)
    
    push = (cb) =>
      logger(status: 'Uploading package...')
      
      size = 0
      stream = deployment_file.create_read_stream()
      stream.on 'data', (data) ->
        size += Buffer.byteLength(data.toString())
        logger(status: 'Uploaded ' + size + ' bytes...')
      
      @app_client.update stream, (err, data) ->
        deployment_file.unlink_sync()
        console.log arguments
        cb(err, data)
    
    steps = []
    steps.push(create_app) unless @get('is_remote')
    steps.push(create_package, push)
    
    async.series steps, (err) =>
      @set(is_shipping: false)
      return callback(err) if err?
      callback()

module.exports = App
