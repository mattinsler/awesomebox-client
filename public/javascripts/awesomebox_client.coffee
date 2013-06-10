class AwesomeboxClient extends Backbone.Model
  root: ''
  
  initialize: ->
    @config = window.__bootstrap__.config
    @set(user: window.__bootstrap__.user) if window.__bootstrap__?.user?

    @set(online: @has('user'))
  
  start: ->
    @clock = new Clock([10, 30])
    @socket = new Socket()
    @socket.on 'message', (data) =>
      console.log data
      
      if data.user isnt undefined
        @set(
          user: data.user
          online: data.user isnt null
        )
    
    @socket.connect('/socket')
    
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
