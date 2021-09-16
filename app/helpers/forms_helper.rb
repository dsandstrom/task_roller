# frozen_string_literal: true

module FormsHelper
  def form_errors(obj)
    return if obj.errors.none?

    title = "Couldn't save the form"
    content_tag :div, class: 'error error-card' do
      concat content_tag(:h3, title, class: 'card-title')
      concat form_errors_messages(obj)
    end
  end

  def required_field_label(form, field_name, value = nil)
    content_tag :div, class: 'field-label-and-message' do
      concat form.label(field_name, value)
      concat content_tag :span, 'required', class: 'field-message'
    end
  end

  def hidden_required_field_label(form, field_name, value = nil)
    content_tag :div, class: 'field-label-and-message' do
      concat form.label(field_name, value)
      concat content_tag :span, 'required', class: 'field-message hide'
    end
  end

  def searching?
    params[:order].present?
  end

  private

    def form_errors_list(obj)
      content_tag :ol do
        obj.errors.full_messages.each do |message|
          concat content_tag(:li, message)
        end
      end
    end

    def form_errors_messages(obj)
      message_count =
        "Please correct the #{pluralize(obj.errors.count, 'error')} below:"

      content_tag :div, class: 'card-body' do
        concat content_tag(:p, message_count)
        concat form_errors_list(obj)
      end
    end
end
