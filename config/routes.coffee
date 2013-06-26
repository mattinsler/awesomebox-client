module.exports = ->
  @route '/', 'application'
  
  @route 'post commands/:id', 'commands#execute'
  @resources 'apps', ->
    @resources 'versions'
  
  @resources 'fs'
