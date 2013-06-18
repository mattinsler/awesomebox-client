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
  
  submit: (evt) ->
    evt?.preventDefault?()
    
    App.rpc.call 'apps:new', {
      template: @get('template').id
      directory: @$('[name="directory"]').val()
    }, () ->
      console.log arguments
    
    false
  
  render: ->
    App.rpc.call 'fs:root', (err, data) =>
      @$('[name="directory"]').val(data) if data?
    
    @templates = new Backbone.Collection([
      new Backbone.Model(
        id: 'bootstrap-example'
        name: 'Bootstrap Example'
        description: 'Simple Hello World app using Twitter Bootstrap'
        image: 'http://twitter.github.io/bootstrap/assets/img/examples/bootstrap-example-marketing.png'
      )
      new Backbone.Model(
        id: 'blank'
        name: 'Blank'
        description: 'Blank app'
        image: ''
        selected: true
      )
    ])
    new CollectionView(
      el: @$('.template-list')
      item_view: (opts) =>
        opts.parent_view = @
        new NewAppTemplateView(opts)
      collection: @templates
    ).render()
