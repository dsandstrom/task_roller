# frozen_string_literal: true

module RollerTypesHelper
  def issue_type_tag(issue_type)
    css_class = "issue-type-tag #{roller_type_color(issue_type)}"

    roller_type_tag issue_type, css_class
  end

  def task_type_tag(task_type)
    css_class = "task-type-tag #{roller_type_color(task_type)}"

    roller_type_tag task_type, css_class
  end

  def roller_type_icon_options
    RollerType::ICON_OPTIONS.map { |t| [t.titleize, t] }
  end

  def roller_type_color_options
    RollerType::COLOR_OPTIONS.map { |t| [t.titleize, t] }
  end

  private

    def roller_type_tag(roller_type, css_class)
      icon = roller_type_icon(roller_type)
      content_tag :span, class: css_class do
        concat icon
        concat roller_type.name
      end
    end

    def roller_type_color(roller_type)
      "roller-type-color-#{roller_type.color}"
    end

    def roller_type_icon(roller_type)
      content_tag :i, '', class: "icon-#{roller_type.icon}"
    end
end
