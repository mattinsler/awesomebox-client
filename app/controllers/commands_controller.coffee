{spawn} = require 'child_process'
ApplicationController = Caboose.get('ApplicationController')

class CommandsController extends ApplicationController
  execute: ->
    switch @params.id
      when 'open'
        require('open')(@body.url)
        return @respond_json(200, 'ok')
      # when 'start_local'
      #   proc = spawn(AWESOMEBOX_PATH, ['run'], cwd: @body.directory)
      #   on_exit = -> proc?.kill()
      #   process.on('exit', on_exit)
      #   
      #   proc.on 'close', ->
      #     process.removeListener('exit', on_exit)
      #     delete proc
