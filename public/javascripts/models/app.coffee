class App.App extends Backbone.Model
  initialize: ->
    unless @id?
      if @has('_id')
        @id = @get('_id') 
        @unset('_id')
      else if @has('user')
        @id = "#{@get('user')}:#{@get('name')}"
      else
        @id = @get('name')
