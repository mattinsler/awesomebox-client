$(document).on 'click', 'ul.expandable-row-list .row-header .expand-contract', ->
  $icon = $('i', @)
  $content = $(@).parents('li').find('.row-content')
  is_visible = $content.is(':visible')
  $content.slideToggle ->
    $icon.toggleClass('glyphicon-chevron-down', is_visible)
    $icon.toggleClass('glyphicon-chevron-up', !is_visible)
