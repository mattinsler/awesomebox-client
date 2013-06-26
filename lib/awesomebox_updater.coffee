request = require 'request'
walkabout = require 'walkabout'
{exec} = require 'child_process'
{EventEmitter} = require 'events'

HOUR = 1000 * 60 * 60
ROOT_DIR = walkabout(Caboose.root.path)
TAG_FILE = ROOT_DIR.join('tag')
PATCH_FILE = ROOT_DIR.join('patch')

last_check = Caboose.app.awesomebox_config.get('last_update_check')
last_check = new Date(last_check) if last_check?

get = (url, callback) ->
  request.get {
    url: url
    headers:
      'User-Agent': 'awesomebox'
    json: true
  }, (err, res, body) ->
    return callback(err) if err?
    return callback(new Error(JSON.stringify(body))) unless parseInt(res.statusCode / 100) is 2
    callback(null, body)

class AwesomeboxUpdater extends EventEmitter
  current_tag: (callback) ->
    tag = ''
    try
      tag = TAG_FILE.read_file_sync().toString()
    catch e
    callback?(null, tag)
    tag
  
  latest_tag: (callback) ->
    get 'https://api.github.com/repos/mattinsler/awesomebox-client/tags', (err, tags) ->
      return callback(err) if err?
      callback(null, tags[0].name)
  
  check_for_update: ->
    current_tag = @current_tag()
    @latest_tag (err, latest_tag) =>
      return console.log(err) if err?
      
      if latest_tag isnt current_tag
        Caboose.app.awesomebox_config.set(update_available: latest_tag)
        @emit('update_available', latest_tag)

      Caboose.app.awesomebox_config.set(last_update_check: new Date())
  
  update: (opts, callback) ->
    if opts.log_channel?
      logger = Caboose.app.bayeux.getClient().publish.bind(Caboose.app.bayeux.getClient(), opts.log_channel)
    else
      logger = ->
    
    current_tag = @current_tag()
    to_tag = Caboose.app.awesomebox_config.get('update_available')
    unless current_tag? and to_tag? and current_tag isnt to_tag
      logger(status: 'Already up to date!')
      return callback(null, false)
    
    logger(status: 'Downloading patch...')
    
    get "https://github.com/mattinsler/awesomebox-client/compare/#{current_tag}...#{to_tag}.diff", (err, diff) ->
      return callback(err) if err?
      
      logger(status: 'Applying patch...')
      
      PATCH_FILE.write_file_sync(diff)
      exec 'patch -N -p1 < ' + PATCH_FILE.absolute_path, {cwd: ROOT_DIR.absolute_path}, ->
        TAG_FILE.write_file_sync(to_tag)
        PATCH_FILE.unlink_sync()
        
        logger(status: 'Restarting...')
        callback(null, true)
        exec(Caboose.root.join('scripts/restart').path, {env: process.env, detached: true})
  
  is_update_available: ->
    Caboose.app.awesomebox_config.get('update_available') or false
  
  start: ->
    available = Caboose.app.awesomebox_config.get('update_available')
    Caboose.app.awesomebox_config.unset('update_available') if available? and @current_tag() is available
    
    setInterval =>
      @check_for_update()
    , 6 * HOUR
    
    @check_for_update() if !last_check? or (last_check.getTime() - 6 * HOUR) > new Date().getTime()

module.exports = AwesomeboxUpdater
