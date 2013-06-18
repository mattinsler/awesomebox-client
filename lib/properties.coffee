_ = require 'underscore'
{EventEmitter} = require 'events'

class Properties extends EventEmitter
  constructor: ->
    @_properties = {}
    
  has: (key) ->
    @_properties[key]?
  
  get: (key) ->
    @_properties[key]
  
  set: (hash, opts = {}) ->
    changed = []
    for k, v of hash
      if @_properties[k] != v
        # old = _.clone(@_properties[k])
        @_properties[k] = v
        @emit('change:' + k, v, opts)
        changed.push(k)
        
    if changed.length > 0
      @emit('change', _(@_properties).pick(changed), opts)
  
  unset: (key, opts = {}) ->
    if @_properties[key]?
      delete @_properties[key]
      @emit('unset:' + key, opts)
      c = {}
      c[key] = undefined
      @emit('change', c, opts)
  
  to_json: ->
    @_properties

module.exports = Properties
