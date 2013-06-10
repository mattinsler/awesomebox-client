$.fn.serializeObject = ->
  o = {}
  $.each @serializeArray(), ->
    if o[@name]
      o[@name] = [o[@name]] unless o[@name].push
      o[@name].push(@value or '')
    else
      o[@name] = @value or ''
  o
