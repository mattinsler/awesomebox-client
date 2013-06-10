encode = (v) -> encodeURIComponent(v).replace('.', '%2E')

class App.VersionCollection extends Backbone.Collection
  model: App.Version
  url: -> "http://api.awesomebox.es/apps/#{encode(@opts.app.get('name'))}/versions?awesomebox-key=#{App.get('user').api_key}"
  
  initialize: (models, opts) ->
    @opts = _(opts).pick('app')
