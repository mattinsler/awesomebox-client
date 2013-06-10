class App.Version extends Backbone.Model
  initialize: ->
    @id = @get('instance').version_name
