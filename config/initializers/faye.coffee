_ = require 'underscore'
faye = require 'faye'
walkabout = require 'walkabout'
AwesomeboxClient = require 'awesomebox.node'
User = Caboose.path.lib.join('user').require()
FayeRpcExtension = Caboose.path.lib.join('faye_rpc_extension').require()

bayeux = Caboose.app.bayeux = new faye.NodeAdapter(mount: '/faye', timeout: 45)

encode = (v) -> encodeURIComponent(v).replace(/\./g, '%2E').replace(/:/g, '%3A').replace(/%/g, '$')
decode = (v) -> decodeURIComponent(v.replace(/\$/g, '%'))

rpc = Caboose.app.rpc = new FayeRpcExtension()
rpc.on 'fs:root', (callback) ->
  callback(null, process.env.HOME)

rpc.on 'awesomebox:login', (opts, callback) ->
  client = new AwesomeboxClient(opts)
  client.user.get (err, user) ->
    return callback?(err) if err?
    
    user = new User(user)
    Caboose.app.awesomebox_config.set(api_key: user.api_key)
    
    bayeux.getClient().publish('/change/user', type: 'user', changes: {user: user})
    callback?(null, user)

rpc.on 'awesomebox:logout', (callback) ->
  Caboose.app.awesomebox_config.unset('api_key')
  
  bayeux.getClient().publish('/change/user', type: 'user', changes: {user: null})
  callback?()

rpc.on 'awesomebox:update-available', (callback) ->
  callback(null, Caboose.app.updater.is_update_available())

rpc.on 'awesomebox:update', (opts, callback) ->
  Caboose.app.updater.update(opts, callback)

rpc.on 'apps:new', (opts, callback) ->
  return callback(new Error('Must specify a template')) unless opts.template?
  return callback(new Error('Must specify a directory')) unless opts.directory? and opts.directory.trim() isnt ''
  
  template_dir = walkabout(Caboose.root.join('app-templates', opts.template).path)
  return callback(new Error('There is not template with ID ' + opts.template)) unless template_dir.exists_sync()
  
  target_dir = walkabout(opts.directory)
  return callback(new Error('Directory must be not exist')) if target_dir.exists_sync()
  
  Caboose.path.lib.join('app').require().create_from_template {
    template: template_dir
    target: target_dir
  }, (err, app) ->
    return callback(err) if err?
    callback(null, Caboose.app.app_repo.add(app).to_json())

rpc.on 'apps:*', (method, opts, callback) ->
  return callback('Must specify an app id') unless opts.id?
  app = Caboose.app.app_repo.get(opts.id)
  return callback('No app with ID ' + opts.id) unless app?
  return callback('Np app method ' + method) unless app[method]?
  app[method](opts, callback)

rpc.on 'app-templates:list', (callback) ->
  Caboose.root.join('app-templates').readdir (err, files) ->
    return callback(err) if err?
    templates = files.filter (f) ->
      f.is_directory_sync() and f.join('template.json').exists_sync()
    .map (f) ->
      a = f.join('template.json').require()
      a.id = f.basename
      a
    callback(null, templates)

Caboose.app.after 'boot', ->
  app_repo = Caboose.app.app_repo
  
  bayeux.attach(Caboose.app.raw_http)
  
  client = bayeux.getClient()
  client.addExtension(rpc)
  
  Caboose.app.updater.on 'update_available', ->
    client.publish('/awesomebox/update-available')
  
  client.addExtension(
    outgoing: (message, callback) ->
      message.channel = '/' + _(message.channel.split('/')).compact().map(encode).join('/')
      callback(message)
  )
  
  client.subscribe '/command/app/**', (message) ->
    app = app_repo.get(message.id)
    app?[message.method]?()
  
  Caboose.app.app_repo.on 'apps:change', (app, changes) ->
    client.publish('/change/app/' + app.id, type: 'app', id: app.id, changes: changes)
