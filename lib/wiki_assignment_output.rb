require './lib/wiki_api'
#= Class for generating wikitext for updating assignment details on talk pages
class WikiAssignmentOutput
  def initialize(course, title, talk_title, assignments)
    @course = course
    @course_page = course.wiki_title
    @wiki = course.home_wiki
    @dashboard_url = ENV['dashboard_url']
    @assignments = assignments
    @title = title
    @talk_title = talk_title
  end

  ###############
  # Entry point #
  ###############
  def self.wikitext(course:, title:, talk_title:, assignments:)
    new(course, title, talk_title, assignments).build_talk_page_update
  end

  ################
  # Main routine #
  ################
  def build_talk_page_update
    initial_page_content = WikiApi.new(@wiki).get_page_content @talk_title
    initial_page_content ||= ''

    # Do not post templates to disambugation pages
    return nil if includes_disambiguation_template?(initial_page_content)

    # We only want to add assignment tags to non-existant talk pages if the
    # article page actually exists, and is not a disambiguation page.
    article_content = WikiApi.new(@wiki).get_page_content(@title)
    return nil if article_content.nil?
    return nil if includes_disambiguation_template?(article_content)

    page_content = build_assignment_page_content(assignments_tag, initial_page_content)
    page_content
  end

  ###################
  # Helper methods #
  ###################
  def assignments_tag
    return '' if @assignments.empty?

    # Make a list of the assignees, role 0
    tag_assigned = build_wikitext_user_list(Assignment::Roles::ASSIGNED_ROLE)
    # Make a list of the reviwers, role 1
    tag_reviewing = build_wikitext_user_list(Assignment::Roles::REVIEWING_ROLE)

    # Build new tag
    # NOTE: If the format of this tag gets changed, then the dashboard may
    # post duplicate tags for the same page, unless we update the way that
    # we check for the presense of existging tags to account for both the new
    # and old formats.
    tag = "{{#{@dashboard_url} assignment | course = #{@course_page}"
    tag += " | assignments = #{tag_assigned}" unless tag_assigned.blank?
    tag += " | reviewers = #{tag_reviewing}" unless tag_reviewing.blank?
    tag += ' }}'

    tag
  end

  # This method creates updated wikitext for an article talk page, for when
  # the set of assigned users for the article for a single course changes.
  # The strategy here is to only update the tag for one course at a time, so
  # that the user who updates the assignments for a course only introduces data
  # for that course. We also want to make as minimal a change as possible, and
  # to make sure that we're not disrupting the format of existing content.
  def build_assignment_page_content(new_tag, page_content)
    # Return if tag already exists on page.
    # However, if the tag is empty, that means to blank the prior tag (if any).
    unless new_tag.blank?
      return nil if page_content.force_encoding('utf-8').include? new_tag
    end

    # Check for existing tags and replace
    old_tag_ex = "{{course assignment | course = #{@course_page}"
    new_tag_ex = "{{#{@dashboard_url} assignment | course = #{@course_page}"
    page_content.gsub!(/#{Regexp.quote(old_tag_ex)}[^\}]*\}\}/, new_tag)
    page_content.gsub!(/#{Regexp.quote(new_tag_ex)}[^\}]*\}\}/, new_tag)

    # Add new tag at top (if there wasn't an existing tag already)
    unless page_content.include?(new_tag)
      # FIXME: Allow whitespace before the beginning of the first template.
      # FIXME: Account for templates within templates, which is common on pages
      # that are part of multiple WikiProjects, where all the project banners are
      # wrapped in another template.

      # Append after existing templates, but only if there is no additional content
      # on the line where the templates end.
      if starts_with_template?(page_content) && end_of_template_is_end_of_line?(page_content)
        page_content.sub!(/\}\}\n(?!\{\{)/, "}}\n#{new_tag}\n")
      else # Add the tag to the top of the page
        page_content = "#{new_tag}\n\n#{page_content}"
      end
    end

    page_content
  end

  def starts_with_template?(page_content)
    page_content[0..1] == '{{'
  end

  def end_of_template_is_end_of_line?(page_content)
    /\}\}\n(?!\{\{)/.match(page_content)
  end

  def build_wikitext_user_list(role)
    user_ids = @assignments.select { |assignment| assignment.role == role }
                           .map(&:user_id)
    User.where(id: user_ids).pluck(:username)
        .map { |username| "[[User:#{username}|#{username}]]" }.join(', ')
  end

  private

  DISAMBIGUATION_TEMPLATE_FRAGMENTS = [
    '{{WikiProject Disambiguation',
    '{{disambig',
    '{{Disambig',
    '{{Dab}}',
    '{{dab}}',
    'disambiguation}}',
    '{{Hndis',
    '{{hndis',
    '{{Geodis',
    '{{geodis'
  ].freeze

  def includes_disambiguation_template?(page_content)
    DISAMBIGUATION_TEMPLATE_FRAGMENTS.any? do |template_fragment|
      page_content.include?(template_fragment)
    end
  end
end
