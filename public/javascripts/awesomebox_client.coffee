class Client
  constructor: (@before_request) ->
  
  encode: (v) -> encodeURIComponent(v).replace('.', '%2E')
  request: (method, path, data, callback) ->
    if typeof data is 'function'
      callback = data
      data = {}
    
    path = '/' + _(path.split('/')).compact().map(@encode).join('/')
    data ?= {}
    # query = _(data).map((v, k) -> encodeURIComponent(k) + '=' + encodeURIComponent(v)).join('&')
    
    config = 
      type: method.toUpperCase()
      url: path
      dataType: 'json'
      data: data
    
    config = @before_request(config) if @before_request?
    
    $.ajax(config).done (data, status) ->
      return callback?(new Error(data)) unless status is 'success'
      callback?(null, data)
  
  get: (path, data, callback) -> @request('get', path, data, callback)
  post: (path, data, callback) -> @request('post', path, data, callback)
  put: (path, data, callback) -> @request('put', path, data, callback)
  delete: (path, data, callback) -> @request('delete', path, data, callback)

class AwesomeboxClient extends Backbone.Model
  root: ''
  
  initialize: ->
    @config = window.__bootstrap__.config
    @set(user: window.__bootstrap__.user) if window.__bootstrap__?.user?

    @set(online: @has('user'))
    @raw_client = new Client()
    @client = new Client(
      (config) =>
        config.url = 'http://api.awesomebox.es' + config.url + '?awesomebox-key=' + @get('user').api_key
        config
    )
  
  start: ->
    @clock = new Clock([10, 30])
    
    @faye = new Faye.Client('/faye')
    @rpc = new FayeRpcExtension()
    @faye.addExtension(@rpc)
    
    encode = (v) -> encodeURIComponent(v).replace(/\./g, '%2E').replace(/:/g, '%3A').replace(/%/g, '$')
    decode = (v) -> decodeURIComponent(v.replace(/\$/g, '%'))
    
    @faye.addExtension(
      outgoing: (message, callback) ->
        message.channel = '/' + _(message.channel.split('/')).compact().map(encode).join('/')
        callback(message)
    )
    
    @faye.subscribe '/change/user', (message) =>
      @set(
        user: message.changes.user
        online: message.changes.user isnt null
      )
    
    @faye.subscribe '/change/app/**', (message) =>
      app = @apps.get(message.id)
      app?.set(message.changes)
    
    @apps = new App.AppCollection()
    @apps.fetch(
      success: =>
        @router = new App.ApplicationRouter()
        @start_backbone(@root)
    )
  
  login: (config, callback) ->
    if typeof config is 'function'
      callback = config
      config = null
    
    $.post('/login', config).complete (res) =>
      return callback(new Error(res.respondJSON)) if res.status isnt 200
      callback?(null, res.responseJSON)
  
  logout: (callback) =>
    $.getJSON '/logout', ->
      callback?()

  start_backbone: (root) ->
    Backbone.history.start(root: root)
    
    $(document).on 'click', 'a:not([data-bypass])', (evt) ->
      href = $(@).prop('href')
      root_href = "#{window.location.protocol}//#{window.location.host}#{root}"

      if href? and href.slice(0, root_href.length) is root_href
        Backbone.history.navigate(href.slice(root_href.length), true)
        evt.preventDefault()
        false
