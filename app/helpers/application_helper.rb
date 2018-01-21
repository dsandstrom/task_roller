# frozen_string_literal: true

module ApplicationHelper
  def form_errors(obj)
    return if obj.errors.none?

    title = 'There was an problem saving the form.'
    content_tag :div, class: 'error error-card' do
      concat content_tag(:h3, title, class: 'card-title')
      concat form_errors_messages(obj)
    end
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
