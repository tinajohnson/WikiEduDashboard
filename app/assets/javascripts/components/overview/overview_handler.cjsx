React         = require 'react'
Actions       = require './actions.cjsx'
Description   = require './description.cjsx'
Milestones    = require './milestones.cjsx'
Details       = require './details.cjsx'
ThisWeek      = require './this_week.cjsx'
CourseStore   = require '../../stores/course_store.coffee'
AssignmentStore = require '../../stores/assignment_store.coffee'
WeekStore     = require '../../stores/week_store.coffee'
ServerActions = require('../../actions/server_actions.js').default
Loading       = require('../common/loading.jsx').default
CourseClonedModal  = require './course_cloned_modal.cjsx'
CourseUtils   = require('../../utils/course_utils.js').default
SyllabusUpload  = require('./syllabus-upload.jsx').default
MyArticles = require('./my_articles.jsx').default
Modal = require('../common/modal.jsx').default

getState = ->
  course: CourseStore.getCourse()
  loading: WeekStore.getLoadingStatus()
  weeks: WeekStore.getWeeks()
  current: CourseStore.getCurrentWeek()

Overview = React.createClass(
  displayName: 'Overview'
  mixins: [WeekStore.mixin, CourseStore.mixin, AssignmentStore.mixin]
  storeDidChange: ->
    @setState getState()
  componentDidMount: ->
    ServerActions.fetch 'timeline', @props.course_id
    ServerActions.fetch 'tags', @props.course_id
  getInitialState: ->
    getState()

  render: ->
    if @props.location.query.modal is 'true' && @state.course.id
      return (
        <CourseClonedModal
          course={@state.course}
          updateCourse={@updateCourse}
          valuesUpdated={@state.valuesUpdated}
        />
      )

    if @props.location.query.syllabus_upload == 'true' && @props.current_user.admin
      syllabus_upload = (
        <Modal modalClass='course__syllabus-upload'>
          <SyllabusUpload {...@props} />
        </Modal>
      )

    no_weeks = !@state.weeks? || @state.weeks.length  == 0
    unless @state.course.legacy || no_weeks
      this_week = (
        <ThisWeek
          course={@state.course}
          weeks={@state.weeks}
          current={@state.current}
        />
      )

    primaryContent = if @state.loading then (
      <Loading />
    ) else (
      <div>
        <Description {...@props} />
        {this_week}
      </div>
    )

    sidebar = if @state.course.id then (
      <div className='sidebar'>
        {userArticles}
        <Details {...@props} />
        <Actions {...@props} />
        <Milestones {...@props} />
      </div>
    ) else (
      <div className='sidebar'>
      </div>
    )

    if @props.current_user.role == 0 && @state.course.id
      userArticles = (
        <MyArticles
          course={@state.course}
          course_id={@props.course_id}
          current_user={@props.current_user}
        />
      )

    <section className='overview container'>
      { syllabus_upload }
      <div className="stat-display">
        <div className="stat-display__stat" id="articles-created">
          <div className="stat-display__value">{@props.course.created_count}</div>
          <small>{I18n.t('metrics.articles_created')}</small>
        </div>
        <div className="stat-display__stat" id="articles-edited">
          <div className="stat-display__value">{@props.course.edited_count}</div>
          <small>{I18n.t('metrics.articles_edited')}</small>
        </div>
        <div className="stat-display__stat" id="total-edits">
          <div className="stat-display__value">{@props.course.edit_count}</div>
          <small>{I18n.t('metrics.edit_count_description')}</small>
        </div>
        <div className="stat-display__stat tooltip-trigger" id="student-editors">
          <div className="stat-display__value">{@props.course.student_count}</div>
          <small>{CourseUtils.i18n('student_editors', @props.course.string_prefix)}</small>
          <div className="tooltip dark" id="trained-count">
            <h4 className="stat-display__value">{@props.course.trained_count}</h4>
            <p>{I18n.t('metrics.are_trained')}</p>
          </div>
        </div>
        <div className="stat-display__stat" id="word-count">
          <div className="stat-display__value">{@props.course.word_count}</div>
          <small>{I18n.t('metrics.word_count')}</small>
        </div>
        <div className="stat-display__stat" id="view-count">
          <div className="stat-display__value">{@props.course.view_count}</div>
          <small>{I18n.t('metrics.view_count_description')}</small>
        </div>
      </div>
      <div className='primary'>
        {primaryContent}
      </div>
      {sidebar}
    </section>
)

module.exports = Overview
