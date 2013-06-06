class App.ApplicationRouter extends Backbone.Router
  initialize: ->
    $('body').html('<header></header><div id="drawer"></div>Hello World')
    @header_view = new App.HeaderView(el: 'header').render()
    @drawer_view = new App.DrawerView(el: '#drawer').render()

  routes:
    'brackets': 'list_brackets'
    'brackets/new': 'new_bracket'
    'brackets/:id': 'show_bracket'
    '*anything': 'index'
  
  index: ->
  #   return @navigate('/brackets', true) if App.has('user')
  #   new App.DumbView(el: '#content', template: 'login', model: {}).render()
  # 
  # list_brackets: ->
  #   new App.BracketListView(el: '#content').render()
  #   
  # new_bracket: ->
  #   new App.NewBracketView(el: '#content').render()
  #   
  # show_bracket: (id) ->
  #   bracket = new App.Bracket(id: id)
  #   bracket.fetch(
  #     success: ->
  #       votes = new App.VoteCollection()
  #       votes.fetch(
  #         success: ->
  #           new App.BracketView(el: '#content', model: bracket).render()
  #       )
  #     error: ->
  #       Backbone.history.navigate('/brackets' , true)
  #   )
