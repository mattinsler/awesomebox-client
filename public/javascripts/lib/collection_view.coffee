stable_sort = (items, comparator) ->
  items.map (item, idx) ->
    {idx: idx, data: item}
  .sort (lhs, rhs) ->
    v = comparator(lhs.data, rhs.data)
    return v unless v is 0
    if lhs.idx < rhs.idx then -1 else 1
  .map (o) ->
    o.data

((exports) ->
  class ListView
    constructor: (opts = {}) ->
      @items = []
      @id_to_item = {}
      _(@).extend(opts)
      @$el = $(@el) if @el?

    get: (id) ->
      @id_to_item[id]

    insert_before: (item, new_item) ->
      $(item.first?.el or item.el).before(new_item.el)

    insert_after: (item, new_item) ->
      $(item.last?.el or item.el).after(new_item.el)

    insert_at: (new_item, index, opts = {}) ->
      return if @id_to_item[new_item.id]?

      if index is 0
        new_item.next = @items[0]

        if @items.length > 0
          @insert_before(@items[0], new_item)
        else if @header?
          @insert_after(@header, new_item)
        else if @footer?
          @insert_before(@footer, new_item)
        else if @prev?
          @insert_after(@prev.last, new_item)
        else if @next?
          @insert_before(@next.first, new_item)
        else if @el?
          @$el.append(new_item.el)
        else if @parent?.el
          @parent.$el.append(new_item.el)
        else
          throw new Error('Cannot insert element')

        new_item.next.prev = new_item if new_item.next?
      else
        # List will always have items in it
        new_item.prev = @items[index - 1]
        new_item.next = @items[index]

        @insert_after(@items[index - 1], new_item)

        new_item.prev.next = new_item
        new_item.next.prev = new_item if new_item.next?


      @id_to_item[new_item.id] = new_item
      @items.splice(index, 0, new_item)
      new_item.parent = @

    add: (item) ->
      return @insert_at(item, 0) if @items.length is 0

      if @comparator?
        idx = _.chain(@items).pluck('data').sortedIndex(item.data, @comparator).value()
        @insert_at(item, idx)
      else
        @insert_at(item, @items.length)

    remove: (id) ->
      item = @get(id)
      delete @id_to_item[item.id]
      @items.splice(@items.indexOf(item), 1)

      item.next.prev = item.prev if item.next?
      item.prev.next = item.next if item.prev?

      $(item.header.el).remove() if item.header?
      $(item.footer.el).remove() if item.footer?
      $(item.el).remove()

      if @items.length is 0 and @parent?
        @parent.remove(@id)

    clear: ->
      for item in @items
        $(item.header.el).remove() if item.header?
        $(item.footer.el).remove() if item.footer?
        $(item.el).remove()

      @items = []
      @id_to_item = {}

    set_header: (header) ->
      if @header?
        @header.el.replaceWith(header.el)
      else
        if @items.length > 0
          @insert_before(@items[0], header)
        else if @footer?
          @insert_before(@footer, header)
        else if @prev?
          @insert_after(@prev.last, header)
        else if @next?
          @insert_before(@next.first, header)
        else if @el?
          @$el.append(header.el)
        else if @parent?.el
          @parent.$el.append(header.el)
        else
          throw new Error('Cannot set header')

      @header = header

    set_footer: (item) ->
      if @footer?
        @footer.el.replaceWith(header.el)
      else
        if @items.length > 0
          @insert_after(@items[@items.length - 1], footer)
        else if @prev?
          @insert_after(@prev.last, footer)
        else if @next?
          @insert_before(@next.first, footer)
        else if @el?
          @$el.append(footer.el)
        else if @parent?.el
          @parent.$el.append(footer.el)
        else
          throw new Error('Cannot set footer')

      @footer = footer

  Object.defineProperty ListView::, 'first', get: -> @header or @items[0]
  Object.defineProperty ListView::, 'last', get: -> @footer or @items[@items.length - 1]



  class Group extends ListView




  class CollectionView2 extends Backbone.View
    initialize: ->
      super

      @visible_count = 0
      @list = new ListView(
        el: @el
        comparator: @options.group?.sort_by
      )

      @collection.on('reset', @on_reset, @)
      @collection.on('add', @on_add, @)
      @collection.on('remove', @on_remove, @)

    unbind: ->
      super
      @collection.off(null, null, @)

    destroy: ->
      super
      for group in @list.items
        for i in group.items
          i.view.destroy()

    show_empty_view: ->
      return if @is_showing_empty_view or !@options.empty?
      @is_showing_empty_view = true

      $(@el).hide()

      if @options.empty.template?
        @empty_template = $(@options.empty.template({}))
        $(@el).after(@empty_template)

    hide_empty_view: ->
      return unless @is_showing_empty_view and @options.empty?
      @is_showing_empty_view = false

      @empty_template.remove() if @empty_template?
      $(@el).show()

    group_item: (item) ->
      if @options.group?.by?
        group_id = @options.group.by(item)
      else
        group_id = 'default'

      group = @list.get(group_id.toString())
      unless group?
        group = new Group(
          id: group_id.toString()
          data: group_id
          comparator: @options.sort_by
        )

        @list.add(group)

        if @options.group?.header?
          header_el = @options.group.header(group)
          $(header_el).hide()
          group.set_header(
            data: group
            el: header_el
          )

        if @options.group?.footer?
          footer_el = @options.group.footer(group)
          $(footer_el).hide()
          group.set_footer(
            data: group
            el: footer_el
          )

      group

    clear: ->
      @visible_count = 0
      for group in @list.items
        for i in group.items
          i.view.destroy()

        @list.clear()

    insert: (model) ->
      view = new @options.item_view(model: model).render()
      group = @group_item(model)
      hide = (@options.filter? and !@options.filter(model))

      if hide
        $(view.el).hide()
      else
        @visible_count += 1
        $(group.header.el).show() if group.header?
        $(group.footer.el).show() if group.footer?

      @hide_empty_view() if @visible_count > 0

      group.add(
        id: model.cid
        data: model
        view: view
        el: view.el
        visible: !hide
      )

    remove: (model) ->
      group = @group_item(model)
      item = group.get(model.cid)
      @visible_count -=1 if item.visible
      group.remove(model.cid)
      item.view.destroy()

    on_reset: ->
      @clear()
      @render()

    on_add: (model, collection, opts) ->
      @insert(model)

    on_remove: (model, collection, opts) ->
      @remove(model)

    render: ->
      @visible_count = 0
      for m in @collection.models
        @insert(m)

      @show_empty_view() if @visible_count is 0

      @

  class CollectionView extends Backbone.View
    initialize: ->
      super

      _.extend(@, _(@options).pick('item_view', 'sort_by', 'filter', 'reverse', 'empty_template', 'empty_view', 'group_by', 'header', 'footer', 'limit'))
      @visible_count = 0
      Object.defineProperty @, 'visible_items', {get: => @items.filter (i) -> i.visible}

      @_sort_by = @sort_by
      Object.defineProperty @, 'sort_by', {
        get: -> @_sort_by
        set: (val) ->
          @_sort_by = val
          @parse_sort_by()
          @_sort_items()
          @render()
      }
      @parse_sort_by()

      @_filter = @filter
      Object.defineProperty @, 'filter', {
        get: -> @_filter
        set: (val) ->
          @_filter = val
          @render()
      }

      @_reverse = @reverse
      Object.defineProperty @, 'reverse', {
        get: -> @_reverse
        set: (val) ->
          @_reverse = val
          @parse_sort_by()
          @_sort_items()
          @render()
      }

      @collection.on('reset', @on_reset, @)
      @collection.on('add', @on_add, @)
      @collection.on('remove', @on_remove, @)

      @parse_items()

    unbind: ->
      super
      @collection.off(null, null, @)

    destroy: ->
      super
      for i in @items when i.view?
        i.view.destroy()
        delete i.view

    parse_items: ->
      @cid_to_item = {}
      if @limit?
        @items = Array::slice.call(@collection.models, 0, @limit-1)
      else
        @items = Array::slice.call(@collection.models)
      @items = @items.map (item, idx) =>
        item_data = {
          item: item
        }
        @cid_to_item[item.cid] = item_data
        item_data

    on_model_changed: ->
      @render()

    parse_sort_by: ->
      if @_sorted_by? and !_.isEqual(@_sorted_by, @_sort_by)
        @collection.off("change:#{k}", @on_model_changed, @) for k in _(@_sorted_by).keys()
        delete @_sorted_by
        delete @_comparator

      return unless @_sort_by

      @_sorted_by = _.clone(@_sort_by)
      @collection.on("change:#{k}", @on_model_changed, @) for k in Object.keys(@_sort_by)

      get_value = (model, key) ->
        v = model.get(key)
        return v.toLowerCase() if typeof v is 'string'
        v

      sort_by = @_sort_by
      reversed = if @_reverse then -1 else 1

      @_comparator = (lhs, rhs) ->
        for k, v of sort_by
          l = get_value(lhs.item, k)
          r = get_value(rhs.item, k)
          continue if l is r

          modifier = reversed * (if v.toLowerCase() in ['desc', 'descending'] then -1 else 1)
          return modifier * (if l > r or not l? then 1 else -1)
        0

    _sort_items: ->
      if @_comparator?
        @items = stable_sort(@items, @_comparator)

      @items[idx].index = idx for idx in [0...@items.length]

    on_reset: ->
      @trigger('before:reset', @)
      for i in @items when i.view?
        i.view.destroy()
        delete i.view
      @parse_items()
      @_sort_items()
      @render()
      @trigger('after:reset', @)

    on_add: (item, collection, options) ->
      return if @cid_to_item[item.cid]?

      item_data = {
        item: item
      }

      @trigger('before:add', item_data, @)

      @items.push(item_data)
      @cid_to_item[item.cid] = item_data

      @_sort_items()

      if !@_filter? or @_filter(item_data.item)
        @add_item_to_view(item_data, transition: 'slideDown')

      @trigger('after:add', item_data, @)

    on_remove: (item, collection, options) ->
      return unless @cid_to_item[item.cid]?

      @trigger('before:remove', item_data, @)

      item_data = @cid_to_item[item.cid]
      delete @cid_to_item[item.cid]

      @remove_item_from_view(item_data, transition: 'slideUp', callback: (item) ->
        item.view.destroy()
        delete item.view
        delete item.rendered
      )

      @items.splice(item_data.index, 1)
      @items[idx].index = idx for idx in [0...@items.length]

      @show_empty() if @visible_items.length is 0

      @trigger('after:remove', item_data, @)

    show_header_and_footer: ->
      if @header? and !@$header_el?
        $header_el = null

        if typeof @header is 'string'
          $header_el = $(@header)
        else if typeof @header is 'function'
          $header_el = @header({})

        if $header_el?
          $header_el.attr('data-role', 'header')
          @$el.prepend($header_el)
          @$header_el = $header_el

      if @footer? and !@$footer_el?
        $footer_el = null

        if typeof @footer is 'string'
          $footer_el = $(@footer)
        else if typeof @footer is 'function'
          $footer_el = @footer({})

        if $footer_el?
          $footer_el.attr('data-role', 'footer')
          @$el.append($footer_el)
          @$footer_el = $footer_el

    hide_header_and_footer: ->
      if @header? and @$header_el?
        @$header_el.remove()
        @$header_el = null
      if @footer? and @$footer_el?
        @$footer_el.remove()
        @$footer_el = null

    add_item_to_view: (item, opts = {}) ->
      @trigger('before:show:item', item, @)

      TRANSITIONS = {
        default: (item, insert) ->
          insert(item)
          item.view.$el.show()
        slideDown: (item, insert) ->
          item.view.$el.hide()
          insert(item)
          item.view.$el.slideDown()
      }

      item.view = new @item_view(model: item.item) unless item.view?

      unless item.rendered
        item.view.render()
        item.rendered = true

      @hide_empty() if @visible_count is 0

      @visible_count += 1 unless item.visible

      transition = TRANSITIONS[opts?.transition] ? TRANSITIONS.default
      if opts.append
        insert = (item) =>
          if @$footer_el?
            return @$footer_el.before(item.view.el)

          @$el.append(item.view.el)
      else
        insert = (item) =>
          if item.index + 1 < @items.length
            next = @items[item.index + 1]
            if next?.view?.el?
              return $(next.view.el).before(item.view.el)
          if item.index - 1 >= 0
            prev = @items[item.index - 1]
            if prev?.view?.el?
              return $(prev.view.el).after(item.view.el)

          if @$heder_el?
            return @$header_el.after(item.view.el)
          if @$footer_el?
            return @$footer_el.before(item.view.el)

          @$el.append(item.view.el)

      transition(item, insert)

      item.visible = true

      @trigger('after:show:item', item, @)
      item.view.trigger('collection_view:after:show', item, @)

    remove_item_from_view: (item, opts = {}) ->
      return unless item.visible

      @trigger('before:hide:item', item, @)

      TRANSITIONS = {
        default: (item, cb) ->
          item.view.$el.hide()
          cb()
        slideUp: (item, cb) ->
          item.view.$el.slideUp(cb)
      }

      transition = TRANSITIONS[opts?.transition] ? TRANSITIONS.default
      transition_complete = =>
        @trigger('after:hide:item', item, @)
        opts.callback?(item)

      if item.visible
        @visible_count -= 1
        transition(item, transition_complete)
      else
        transition_complete()

      item.visible = false

    show_empty: ->
      return if @_showing_empty_template
      @_showing_empty_template = true

      if @empty_template?
        @hide_header_and_footer()

        html = @empty_template({})
        @$el.html(html)

      else if @empty_view?
        @hide_header_and_footer()

        @empty_view.render()

        @$el.empty()
        @$el.append(@empty_view.el)

    hide_empty: ->
      return unless @_showing_empty_template

      @show_header_and_footer()

      if @empty_template?
        @$el.empty()
      if @empty_view?
        @empty_view.destroy()

      # @$el.empty()

      @_showing_empty_template = false

    re_render: ->
      return @render() unless @rendered

      @trigger('before:render', @)

      @visible_count = 0
      @items.forEach (item) =>
        if !@_filter? or @_filter(item.item)
          @add_item_to_view(item, append: true)
        else
          @remove_item_from_view(item)

      @show_empty() if @visible_items.length is 0

      @trigger('after:render', @)

    render: ->
      return @re_render() if @rendered

      @trigger('before:render', @)

      @rendered = true

      @$el.empty()

      @_sort_items()

      @visible_count = 0
      @items.forEach (item) =>
        @add_item_to_view(item) if !@_filter? or @_filter(item.item)

      @show_empty()
      @show_header_and_footer()

      @trigger('after:render', @)

  exports.CollectionView = CollectionView
  exports.CollectionView2 = CollectionView2
  exports.ListView = ListView
)(module?.exports or window)
