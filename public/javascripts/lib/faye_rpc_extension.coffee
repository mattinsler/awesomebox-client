class window.FayeRpcExtension
  constructor: (@prefix = '') ->
    @methods = {}
    @requests = {}
  
  on: (method, callback) ->
    @methods[@prefix + method] = callback
  
  call: (method, args, callback) ->
    if typeof arguments[arguments.length - 1] is 'function'
      callback = arguments[arguments.length - 1]
      args = Array::slice.call(arguments, 1, -1)
    else
      callback = null
      args = Array::slice.call(arguments, 1)
    
    @client.publish('/rpc', method: method, args: args, callback: callback)
  
  added: (@client) ->
    @client.subscribe('/rpc')
  
  handle_response: (message, callback) ->
    cb = @requests[message.data.id]
    delete @requests[message.data.id]
    
    cb?(message.data.error, message.data.response)
    
    message.error = 'Handled by RPC'
    callback(message)
  
  handle_method: (message, callback) ->
    id = message.clientId + ':' + message.id
    
    match = (method) =>
      parts = method.split(':')
      for x in [parts.length..1]
        m = parts.slice(0, x).join(':')
        return m if @methods[m]?
        return m + ':*' if x < parts.length and @methods[m + ':*']?
    
    method_name = match(message.data.method)
    return callback(message) unless method_name?
    method = @methods[method_name]
    return callback(message) unless method?
    
    message.data.args ?= []
    message.data.args.push (err, data) =>
      return unless message.data.callback is true
      return @client.publish('/rpc', id: id, error: err.message) if err?
      @client.publish('/rpc', id: id, response: data)
    
    message.data.args.unshift(message.data.method.slice(method_name.length - 1)) unless message.data.method is method_name
    
    method.apply(null, message.data.args)
  
    message.error = 'Handled by RPC'
    callback(message)
  
  incoming: (message, callback) ->
    return callback(message) unless message.channel is '/rpc' and message.data?
    
    return @handle_response(message, callback) if message.data.id? and (message.data.response? or message.data.error?)
    return @handle_method(message, callback) if message.data.method?
    callback(message)
  
  outgoing: (message, callback) ->
    return callback(message) unless message.channel is '/rpc' and message.data.callback?
    
    id = message.clientId + ':' + message.id
    @requests[id] = message.data.callback
    message.data.callback = true
    callback(message)
