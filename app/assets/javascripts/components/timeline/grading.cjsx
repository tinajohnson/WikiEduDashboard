React             = require 'react'
Gradeable         = require './gradeable.cjsx'
GradeableActions  = require('../../actions/gradeable_actions.js').default
BlockStore        = require '../../stores/block_store.coffee'

Grading = React.createClass(
  displayName: 'Grading'
  render: ->
    total = _.sum(@props.gradeables, 'points')
    gradeables = @props.gradeables.map (gradeable, i) =>
      block = BlockStore.getBlock(gradeable.gradeable_item_id)
      <Gradeable
        gradeable={gradeable}
        block={block}
        key={gradeable.id}
        editable={@props.editable}
        total={total}
      />
    gradeables.sort (a, b) ->
      return 1 unless a.props.gradeable? && b.props.gradeable?
      a.props.gradeable.order - b.props.gradeable.order
    unless gradeables.length
      no_gradeables = (
        <li className="row view-all">
          <div><p>{I18n.t('timeline.gradeables_none')}</p></div>
        </li>
      )

    <div className='grading__grading-container'>
      <a name="grading"></a>
      <div className="section-header timeline__grading-container">
        <h3>{I18n.t('timeline.grading_header', total: total)}</h3>
        {@props.controls(null, @props.gradeables.length < 1)}
      </div>
      <ul className="list-unstyled timeline__grading-container">
        {gradeables}
        {no_gradeables}
      </ul>
    </div>
)

module.exports = Grading
