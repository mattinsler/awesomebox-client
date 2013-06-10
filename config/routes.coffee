module.exports = ->
  @route '/', 'application'
  
  @route 'post /login', 'application#login'
  @route '/logout', 'application#logout'
  
  @resources 'apps', ->
    @resources 'versions'
