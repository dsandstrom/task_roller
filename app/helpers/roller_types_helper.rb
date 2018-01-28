# frozen_string_literal: true

module RollerTypesHelper
  def issue_type_tag(issue_type)
    css_class = "issue-type-tag issue-type-#{issue_type_color(issue_type)}"
    icon = issue_type_icon(issue_type)

    roller_type_tag issue_type.name, icon, css_class
  end

  private

    def roller_type_tag(name, icon, css_class)
      content_tag :span, class: css_class do
        concat icon
        concat name
      end
    end

    def issue_type_color(issue_type)
      "color-#{issue_type.color}"
    end

    def issue_type_icon(issue_type)
      content_tag :i, '', class: "icon-#{issue_type.icon}"
    end
end
