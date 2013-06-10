class window.Clock extends Backbone.Model
  initialize: (@intervals = []) ->
    @set(time: new Date(), false)
    setInterval(@update.bind(@), 1000)

  update: ->
    time = new Date()
    secs = parseInt(time.getTime() / 1000)
    @set(time: time)
    for i in @intervals
      @set('every_' + i + '_sec': time) if secs % i
  
  now: ->
    @get('time')

  now_m: ->
    moment(@now())
