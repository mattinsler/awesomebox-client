class NewAppTemplateView extends Backbone.View
  template: @template('new-app-template')
  initialize: (opts) ->
    @parent_view = opts.parent_view if opts.parent_view?
    Spellbinder.initialize(@, replace: true)
  
  select: ->
    @parent_view.set(template: @model)

class App.NewAppDialog extends App.Dialog
  template: @template('new-app')
  constructor: ->
    super
    _(@).extend(new Backbone.Model())
  
  initialize: ->
    Spellbinder.initialize(@, replace: true)
    @templates = new Backbone.Collection()
  
  submit: (evt) ->
    evt?.preventDefault?()
    
    App.rpc.call 'apps:new', {
      template: @get('template').id
      directory: @$('[name="directory"]').val()
    }, (err, app) =>
      return console.log(err) if err?
      App.apps.add(app)
      Backbone.history.navigate(app.id, true)
      @hide()
    
    false
  
  render: ->
    App.rpc.call 'fs:root', (err, data) =>
      @$('[name="directory"]').val(data) if data?
    App.rpc.call 'app-templates:list', (err, data) =>
      @templates.add(data) if data?
    
    @$('[name="directory"]').typeahead(
      name: 'directory'
      remote: 'fs?path=%QUERY'
      limit: 10
    )
    
    new CollectionView(
      el: @$('.template-list')
      item_view: (opts) =>
        opts.parent_view = @
        new NewAppTemplateView(opts)
      collection: @templates
    ).render()
