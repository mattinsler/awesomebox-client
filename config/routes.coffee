module.exports = ->
  @route '/', 'application'
  
  @route 'post /login', 'application#login'
  @route '/logout', 'application#logout'
  
  @route 'post commands/:id', 'commands#execute'
  @resources 'apps', ->
    @resources 'versions'
