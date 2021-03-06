#=Controller for the Revisions API.
class RevisionsController < ApplicationController
  respond_to :json
  DEFAULT_REVISION_LIMIT = 10

  # Returns revisions for a single user within the scope of a single course.
  def index
    user = User.find(params[:user_id])
    course = Course.find(params[:course_id])

    @revisions = course.revisions.where(user_id: user.id)
                       .order('revisions.created_at DESC')
                       .eager_load(:article)
                       .limit(params[:limit] || DEFAULT_REVISION_LIMIT)
  end
end
