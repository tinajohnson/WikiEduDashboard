require 'csv'

class Survey < ActiveRecord::Base
  has_paper_trail
  has_many :survey_assignments, dependent: :destroy
  has_and_belongs_to_many :rapidfire_question_groups,
                          class_name: 'Rapidfire::QuestionGroup',
                          join_table: 'surveys_question_groups',
                          association_foreign_key: 'rapidfire_question_group_id'
  accepts_nested_attributes_for :rapidfire_question_groups

  def status
    return '--' if closed
    active = survey_assignments.map(&:active?)
    return "In Use (#{active.count})" unless active.empty?
    '--'
  end

  CSV_HEADER = [
    'Question Group',
    'Grouped Question',
    'Question Id',
    'Question',
    'Answer',
    'Follow Up Question',
    'Follow Up Answer',
    'User',
    'User Role',
    'Course Slug',
    'Course Cohorts',
    'Course Tags'
  ].freeze

  def to_csv
    CSV.generate do |csv|
      csv << CSV_HEADER
      rapidfire_question_groups.each do |question_group|
        question_group.questions.each do |question|
          question.answers.each do |answer|
            csv << csv_row(question_group, question, answer)
          end
        end
      end
    end
  end

  private

  def csv_row(question_group, question, answer)
    course = answer.course(id)
    course_slug = course.nil? ? nil : course.slug
    cohorts = course.nil? ? nil : course.cohorts.collect(&:title).join(', ')
    tags = course.nil? ? nil : course.tags.collect(&:tag).join(', ')

    [
      question_group.name,
      question.validation_rules[:grouped_question],
      question.id,
      question.question_text,
      answer.answer_text,
      question.follow_up_question_text,
      answer.follow_up_answer_text,
      answer.user.username,
      answer.courses_user_role(id),
      course_slug,
      cohorts,
      tags
    ]
  end
end
