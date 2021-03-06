require 'rake'
require "#{Rails.root}/lib/surveys/survey_notifications_manager"

WikiEduDashboard::Application.load_tasks

class SurveyAssignmentsController < ApplicationController
  before_action :require_admin_permissions
  before_action :set_survey_assignment, only: [:show, :edit, :update, :destroy]
  before_action :set_survey_assignment_options, only: [:new, :edit, :update]
  layout 'surveys'
  include SurveyAssignmentsHelper

  # GET /survey_assignments
  # GET /survey_assignments.json
  def index
    @survey_assignments = SurveyAssignment.all
  end

  # GET /survey_assignments/1
  # GET /survey_assignments/1.json
  def show
  end

  # GET /survey_assignments/new
  def new
    @survey_assignment = SurveyAssignment.new
  end

  # GET /survey_assignments/1/edit
  def edit
  end

  # POST /survey_assignments
  def create
    @survey_assignment = SurveyAssignment.new(survey_assignment_params)

    if @survey_assignment.save
      redirect_to survey_assignments_path, notice: 'Survey assignment was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /survey_assignments/1
  def update
    if @survey_assignment.update(survey_assignment_params)
      redirect_to survey_assignments_path, notice: 'Survey assignment was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /survey_assignments/1
  def destroy
    @survey_assignment.destroy!
    redirect_to survey_assignments_url, notice: 'Survey assignment was successfully destroyed.'
  end

  def create_notifications
    SurveyNotificationsManager.create_notifications
    flash[:notice] = 'Creating Survey Notifications'
    redirect_to survey_assignments_path
  end

  def send_notifications
    SurveyNotification.active.each do |notification|
      next unless notification.survey_assignment.send_email?
      notification.send_email
    end
    flash[:notice] = 'Sending Email Survey Notifications (if enabled)'
    redirect_to survey_assignments_path
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_survey_assignment
    @survey_assignment = SurveyAssignment.find(params[:id])
  end

  def set_survey_assignment_options
    @send_relative_to_options = SEND_RELATIVE_TO_OPTIONS
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def survey_assignment_params
    params.require(:survey_assignment)
          .permit(:survey_id, :send_before, :send_date_relative_to,
                  :send_date_days, :courses_user_role, :published,
                  :follow_up_days_after_first_notification, :send_email,
                  :notes, cohort_ids: [])
  end
end
