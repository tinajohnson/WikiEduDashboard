require 'uri'
require "#{Rails.root}/lib/assignment_manager"

# Controller for Assignments
class AssignmentsController < ApplicationController
  respond_to :json
  before_action :require_participating_user,
                only: [:create]

  def index
    set_course
    @assignments = Assignment.where(user_id: params[:user_id],
                                    role: params[:role],
                                    course_id: @course.id)
    render json: @assignments
  end

  def destroy
    id = params[:id]
    @assignment = Assignment.find(id)
    @course = @assignment.course
    check_permissions(@assignment.user_id)
    update_onwiki_course_and_assignments
    remove_assignment_template
    @assignment.destroy
    render json: { article: id }
  end

  def create
    set_course
    check_permissions(assignment_params[:user_id].to_i)
    set_wiki
    @assignment = AssignmentManager.new(user_id: assignment_params[:user_id],
                                        course: @course,
                                        wiki: @wiki,
                                        title: assignment_params[:article_title],
                                        role: assignment_params[:role]).create_assignment
    update_onwiki_course_and_assignments
    render json: @assignment
  end

  private

  def update_onwiki_course_and_assignments
    WikiCourseEdits.new(action: :update_assignments, course: @course, current_user: current_user)
    WikiCourseEdits.new(action: :update_course, course: @course, current_user: current_user)
  end

  def remove_assignment_template
    WikiCourseEdits.new(action: :remove_assignment,
                        course: @course,
                        current_user: current_user,
                        assignment: @assignment)
  end

  def set_course
    @course = Course.find_by_slug(URI.unescape(params[:course_id]))
  end

  def set_wiki
    home_wiki = @course.home_wiki
    language = params[:language] || home_wiki.language
    project = params[:project] || home_wiki.project
    @wiki = Wiki.find_by(language: language, project: project)
    @wiki ||= home_wiki
  end

  def check_permissions(user_id)
    exception = ActionController::InvalidAuthenticityToken.new('Unauthorized')
    raise exception unless user_signed_in?
    return if current_user.id == user_id
    return if current_user.can_edit?(@course)
    raise exception
  end

  def assignment_params
    params.permit(:user_id, :course_id, :article_title, :role, :language, :project)
  end
end
