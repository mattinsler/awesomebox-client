# Override Backbone.sync
# _sync = Backbone.sync
# Backbone.sync = (method, model, options) ->
#   url = _(model).result('url')
#   url = '/' + url unless url[0] is '/'
#   options.url = window.__bootstrap__.config.api_url + url
#   _sync(method, model, options)

Backbone.View.template = (name) ->
  html = $('#templates [data-name="' + name + '"]').html()
  ejs.compile(html)

$.ajaxPrefilter (options, originalOptions, jqXHR) ->
  options.xhrFields = {
    withCredentials: true
  }

window.App = new AwesomeboxClient()

$ -> window.App.start()
