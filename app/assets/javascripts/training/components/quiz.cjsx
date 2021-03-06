React  = require 'react'
TrainingStore = require '../stores/training_store.coffee'
TrainingActions = require('../actions/training_actions.js').default
md              = require('../../utils/markdown_it.js').default()


Quiz = React.createClass(
  setSelectedAnswer: (id) ->
    TrainingActions.setSelectedAnswer(id)
  verifyAnswer: (e) ->
    e.preventDefault()
    e.stopPropagation()
    @setSelectedAnswer(@state.selectedAnswerId)
  setAnswer: (e) ->
    @setState selectedAnswerId: e.currentTarget.getAttribute('data-answer-id')
  componentWillReceiveProps: (newProps) ->
    @setState selectedAnswerId: newProps.selectedAnswerId
  correctStatus: (answer) ->
    if @props.correctAnswer == answer then ' correct' else ' incorrect'
  visibilityStatus: (answer) ->
    if @props.selectedAnswer == answer then ' shown' else ' hidden'
  getInitialState: ->
    selectedAnswerId: @props.selectedAnswerId
  render: ->
    answers = @props.answers.map (answer, i) =>
      explanationClass = "assessment__answer-explanation"
      explanationClass += @correctStatus(answer.id)
      explanationClass += @visibilityStatus(answer.id)
      defaultChecked = parseInt(@props.selectedAnswer) == answer.id
      checked = if @state.selectedAnswerId? then parseInt(@state.selectedAnswerId) == answer.id else defaultChecked
      liClass = if @visibilityStatus(answer.id) == ' shown' then ' revealed'
      liClass += @correctStatus(answer.id)
      raw_explanation_html = md.render(answer.explanation)
      <li key={i} className={liClass}>
        <label>
          <div>
            <input
              onChange={@setAnswer}
              data-answer-id={answer.id}
              defaultChecked={defaultChecked}
              checked={checked}
              type="radio"
              name="answer" />
          </div>
          {answer.text}
        </label>
        <div className={explanationClass} dangerouslySetInnerHTML={{__html: raw_explanation_html}}></div>
      </li>

    <form className="training__slide__quiz">
      <h3>{@props.question}</h3>
      <fieldset>
        <ul>
          {answers}
        </ul>
      </fieldset>
      <button className="btn btn-primary ghost-button capitalize btn-med" onClick={@verifyAnswer}>Check Answer</button>
    </form>


)

module.exports = Quiz
