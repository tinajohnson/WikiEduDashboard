React           = require 'react'
UIActions       = require('../../actions/ui_actions.js').default

List = React.createClass(
  displayName: 'List'
  render: ->
    sorting = @props.store.getSorting()
    sortClass = if sorting.asc then 'asc' else 'desc'
    headers = []
    for key in Object.keys(@props.keys)
      key_obj = @props.keys[key]
      header_class = if sorting.key == key then sortClass else ''
      header_class += if key_obj['desktop_only'] then ' desktop-only-tc' else ''
      unless (@props.sortable? && !@props.sortable) || (key_obj['sortable']? && !key_obj['sortable'])
        header_class += ' sortable'
        header_onclick = UIActions.sort.bind(null, @props.table_key, key)
      else
        header_onclick = null
      if key_obj['info_key']?
        header_class += ' tooltip-trigger'
        tooltip = [(
          <div key="tt" className='tooltip dark'>
            <p>{I18n.t(key_obj['info_key'])}</p>
          </div>
        ), (
          <span key="ttindicator" className="tooltip-indicator"></span>
        )]
      else
        tooltip = null
      headers.push (
        <th onClick={header_onclick} className={header_class} key={key}>
          <span dangerouslySetInnerHTML={{__html: key_obj['label']}}></span>
          <span className="sortable-indicator"></span>
          {tooltip}
        </th>
      )


    className = @props.table_key + ' table '

    if @props.className then className += @props.className

    if @props.sortable then className += ' table--sortable'

    elements = @props.elements
    if elements.length == 0
      if @props.store.isLoaded()
        text = @props.none_message
        text ||= I18n.t(@props.table_key + '.none')
      else
        text = I18n.t(@props.table_key + '.loading')
      elements = (
        <tr className='disabled'>
          <td colSpan={headers.length + 1} className='text-center'>
            <span>{text}</span>
          </td>
        </tr>
      )

    <table className={className}>
      <thead>
        <tr>
          {headers}
          <th></th>
        </tr>
      </thead>
      <tbody>
        {elements}
      </tbody>
    </table>
)

module.exports = List
