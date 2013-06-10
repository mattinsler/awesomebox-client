class window.Socket
  constructor: ->
    _(@).extend(Backbone.Events)
    @_connection = null
    @_should_connect = true
  
  disconnect: ->
    return unless @_connection?
    @_should_connect = false
    @_connection.close()
  
  connect: (endpoint) ->
    return if @_connection?
    @_should_connect = true
    conn = new SockJS(endpoint)
    
    on_message = (e) =>
      console.log '[.] message', e.data
      @trigger('message', JSON.parse(e.data))
    
    conn.onopen = =>
      console.log '[*] open', conn.protocol
      @_connection = conn
      @_connection.onmessage = on_message
      @trigger('connect')
    
    conn.onclose = =>
      console.log '[*] close'
      if @_connection?
        @_connection.onmessage = null
        delete @_connection
        @_connection = null
      @trigger('disconnect')
      
      return unless @_should_connect is true
      setTimeout =>
        @connect(endpoint)
      , 1000
    @
  
  send: (message) ->
    @_connection.send(JSON.stringify(message))
