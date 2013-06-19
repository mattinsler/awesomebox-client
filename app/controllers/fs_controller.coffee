walkabout = require 'walkabout'
ApplicationController = Caboose.get('ApplicationController')

class FsController extends ApplicationController
  index: ->
    path = walkabout(@query.path)
    lower_path = path.absolute_path.toLowerCase()
    
    path = path.directory() unless path.exists_sync() and path.is_directory_sync()
    
    path.readdir (err, files) =>
      return @respond_json(500, error: err.message) if err?
      
      files = files.map (f) ->
        f.absolute_path
      .filter (f) ->
        f.toLowerCase().indexOf(lower_path) is 0
      
      @respond_json(200, files)
