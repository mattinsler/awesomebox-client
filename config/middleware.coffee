express = require 'express'
flash = require 'connect-flash'
compiler = require 'connect-compiler'
less_middleware = require 'less-middleware'

module.exports = (http) ->
  http.use express.logger()
  http.use express.bodyParser()
  http.use express.methodOverride()
  http.use express.cookieParser()
  http.use express.session(secret: 'some kind of random string')
  http.use flash()
  http.use -> Caboose.app.router.route.apply(Caboose.app.router, arguments)
  http.use compiler(
    enabled: ['coffee']
    src: 'public'
    dest: 'public_compiled'
  )
  http.use less_middleware(src: Caboose.root.join('public').path, dest: Caboose.root.join('public_compiled').path)
  http.use express.static(Caboose.root.join('public_compiled').path)
  http.use express.static(Caboose.root.join('public').path)
