# Override Backbone.sync
_sync = Backbone.sync
Backbone.sync = (method, model, options) ->
  url = _(model).result('url')
  url = '/' + url unless url[0] is '/'
  options.url = window.__bootstrap__.config.api_url + url
  _sync(method, model, options)

class Application extends Backbone.Model
  root: ''
  
  initialize: ->
    @config = window.__bootstrap__.config
    @set(user: window.__bootstrap__.user) if window.__bootstrap__?.user?
  
  start: ->
    @router = new App.ApplicationRouter()
    @start_backbone(@root)

  start_backbone: (root) ->
    Backbone.history.start(root: root)

    $(document).on 'click', 'a:not([data-bypass])', (evt) ->
      href = $(@).prop('href')
      root_href = "#{window.location.protocol}//#{window.location.host}#{root}"

      if href? and href.slice(0, root_href.length) is root_href
        Backbone.history.navigate(href.slice(root_href.length), true)
        evt.preventDefault()
        false

Backbone.View.template = (name) ->
  html = $('#templates [data-name="' + name + '"]').html()
  ejs.compile(html)

$.ajaxPrefilter (options, originalOptions, jqXHR) ->
  options.xhrFields = {
    withCredentials: true
  }

window.App = new Application()

$ -> window.App.start()
