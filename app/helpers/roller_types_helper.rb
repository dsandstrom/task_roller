# frozen_string_literal: true

module RollerTypesHelper
  def issue_type_tag(issue_type)
    return unless issue_type

    roller_type_tag issue_type,
                    "issue-type-tag #{roller_type_color(issue_type)}"
  end

  def task_type_tag(task_type)
    return unless task_type

    roller_type_tag task_type, "task-type-tag #{roller_type_color(task_type)}"
  end

  def issue_type_icon_tag(issue_type)
    return unless issue_type

    roller_type_icon_tag issue_type,
                         "issue-type-icon #{roller_type_color(issue_type)}"
  end

  def task_type_icon_tag(task_type)
    return unless task_type

    roller_type_icon_tag task_type,
                         "task-type-icon #{roller_type_color(task_type)}"
  end

  def roller_type_icon(roller_type)
    return unless roller_type

    content_tag :i, '', class: "icon-#{roller_type.icon}"
  end

  def roller_type_icon_options
    RollerType::ICON_OPTIONS.map { |t| [t.titleize, t] }
  end

  def roller_type_color_options
    RollerType::COLOR_OPTIONS.map { |t| [t.titleize, t] }
  end

  private

    def roller_type_tag(roller_type, css_class)
      content_tag :span, class: css_class do
        concat roller_type_icon(roller_type)
        concat content_tag(:span, roller_type.name)
      end
    end

    def roller_type_icon_tag(roller_type, css_class)
      content_tag :span, class: css_class do
        concat roller_type_icon(roller_type)
      end
    end

    def roller_type_color(roller_type)
      "roller-type-color-#{roller_type.color}"
    end
end
