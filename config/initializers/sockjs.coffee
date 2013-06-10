_ = require 'underscore'
sockjs = require 'sockjs'
{EventEmitter} = require 'events'

connections = []

sock_server = sockjs.createServer(sockjs_url: 'http://cdn.sockjs.org/sockjs-0.3.min.js')
sock_server.on 'connection', (conn) ->
  connections.push(conn)
  
  conn.on 'close', ->
    connections = _(connections).without(conn)
  
  conn.on 'data', (data) ->
    data = JSON.parse(data)
    Caboose.app.socket.emit('data', data)


Caboose.app.socket = new EventEmitter()
Caboose.app.socket.send = (data) ->
  data = JSON.stringify(data)
  c.write(data) for c in connections


Caboose.app.after 'boot', ->
  sock_server.installHandlers(Caboose.app.raw_http, prefix: '/socket')
