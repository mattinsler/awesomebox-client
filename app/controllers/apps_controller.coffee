_ = require 'underscore'
ApplicationController = Caboose.get('ApplicationController')

class AppsController extends ApplicationController
  index: ->
    @respond_with(_(Caboose.app.app_repo.apps).invoke('to_json'))
