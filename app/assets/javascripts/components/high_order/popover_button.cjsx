React         = require 'react'
Expandable    = require('../high_order/expandable.jsx').default
Popover       = require('../common/popover.jsx').default
Conditional   = require('../high_order/conditional.jsx').default
ServerActions = require('../../actions/server_actions.js').default
Lookup        = require('../common/lookup.jsx').default
LookupSelect  = require('../common/lookup_select.jsx').default
{ capitalize } = require('../../utils/strings.js')

PopoverButton = (Key, ValueKey, Store, New, Items, IsSelect=false) ->
  getState = ->
    exclude: _.pluck(Store.getModels(), ValueKey)
  format = (value) ->
    data = {}
    data[Key] = {}
    data[Key][ValueKey] = value
    return data
  component = React.createClass(
    displayname: capitalize(Key) + 'Button'
    mixins: [Store.mixin]
    storeDidChange: ->
      if @refs.entry?
        item = @refs.entry.getValue()
        if !New(item)
          @refs.entry.clear()
      @setState getState()
    getInitialState: ->
      getState()
    add: (e) ->
      e.preventDefault() if e.preventDefault?
      item = @refs.entry.getValue()
      if New(item)
        ServerActions.add Key, @props.course_id, format(item)
      else
        alert I18n.t('courses.already_exists')
    remove: (item_id) ->
      item = Store.getFiltered({ id: item_id })[0]
      ServerActions.remove Key, @props.course_id, format(item[ValueKey])
    stop: (e) ->
      e.stopPropagation()
    getKey: ->
      Key + '_button'
    render: ->
      placeholder = capitalize(Key)
      if IsSelect
        lookup = (
          <LookupSelect model={Key}
            exclude={@state.exclude}
            placeholder={placeholder}
            ref='entry'
            onSubmit={@add}
          />
        )
      else
        lookup = (
          <Lookup model={Key}
            exclude={@state.exclude}
            placeholder={placeholder}
            ref='entry'
            onSubmit={@add}
          />
        )
      edit_row = (
        <tr className='edit'>
          <td>
            <form onSubmit={@add}>
              {lookup}
              <button type="submit" className='button border'>Add</button>
            </form>
          </td>
        </tr>
      )

      <div className='pop__container' onClick={@stop}>
        <button className='button border plus' onClick={@props.open}>+</button>
        <Popover
          is_open={@props.is_open}
          edit_row={edit_row}
          rows={Items(@props, @remove)}
        />
      </div>
  )
  return Conditional(Expandable(component))


module.exports = PopoverButton
