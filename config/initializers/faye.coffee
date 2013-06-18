_ = require 'underscore'
faye = require 'faye'
FayeRpcExtension = Caboose.path.lib.join('faye_rpc_extension').require()

bayeux = Caboose.app.bayeux = new faye.NodeAdapter(mount: '/faye', timeout: 45)

encode = (v) -> encodeURIComponent(v).replace(/\./g, '%2E').replace(/:/g, '%3A').replace(/%/g, '$')
decode = (v) -> decodeURIComponent(v.replace(/\$/g, '%'))

rpc = Caboose.app.rpc = new FayeRpcExtension()
rpc.on 'fs:root', (callback) ->
  callback(null, process.env.HOME)

rpc.on 'apps:new', (opts, callback) ->
  console.log opts
  callback(null, false)

rpc.on 'apps:*', (method, opts, callback) ->
  return callback('Must specify an app id') unless opts.id?
  app = Caboose.app.app_repo.get(opts.id)
  return callback('No app with ID ' + opts.id) unless app?
  return callback('Np app method ' + method) unless app[method]?
  app[method]()
  callback()


Caboose.app.after 'boot', ->
  app_repo = Caboose.app.app_repo
  
  bayeux.attach(Caboose.app.raw_http)
  
  client = bayeux.getClient()
  client.addExtension(rpc)
  
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
