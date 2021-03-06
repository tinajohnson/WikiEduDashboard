# == Schema Information
#
# Table name: revisions
#
#  id             :integer          not null, primary key
#  characters     :integer          default(0)
#  created_at     :datetime
#  updated_at     :datetime
#  user_id        :integer
#  article_id     :integer
#  views          :integer          default(0)
#  date           :datetime
#  new_article    :boolean          default(FALSE)
#  deleted        :boolean          default(FALSE)
#  system         :boolean          default(FALSE)
#  wp10           :float(24)
#  wp10_previous  :float(24)
#  ithenticate_id :integer
#  wiki_id        :integer
#  mw_rev_id      :integer
#  mw_page_id     :integer
#

#= Revision model
class Revision < ActiveRecord::Base
  belongs_to :user
  belongs_to :article
  belongs_to :wiki
  scope :after_date, -> (date) { where('date > ?', date) }
  scope :live, -> { where(deleted: false) }
  scope :user, -> { where(system: false) }

  # Helps with importing data
  alias_attribute :rev_id, :mw_rev_id

  validates :mw_page_id, presence: true
  validates :mw_rev_id, presence: true
  validates :wiki_id, presence: true

  serialize :features

  include ArticleHelper

  ####################
  # Instance methods #
  ####################
  def url
    # https://en.wikipedia.org/w/index.php?title=Eva_Hesse&diff=prev&oldid=655980945
    return if article.nil?
    title = escaped_full_title(article)
    "#{wiki.base_url}/w/index.php?title=#{title}&diff=prev&oldid=#{mw_rev_id}"
  end

  def update(data={}, save=true)
    self.attributes = data
    self.save if save
  end

  def infer_courses_from_user
    return [] if user.blank?
    user.courses.where('start <= ?', date).where('end >= ?', date)
  end

  def plagiarism_report_link
    return unless ithenticate_id
    "/recent-activity/plagiarism/report?ithenticate_id=#{ithenticate_id}"
  end
end
