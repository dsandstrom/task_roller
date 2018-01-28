# frozen_string_literal: true

module ApplicationHelper
  FLASH_MESSSAGE_TYPES = { 'notice' => 'primary', 'success' => 'success',
                           'error' => 'warning' }.freeze

  def form_errors(obj)
    return if obj.errors.none?

    title = "Couldn't save the form"
    content_tag :div, class: 'error error-card' do
      concat content_tag(:h3, title, class: 'card-title')
      concat form_errors_messages(obj)
    end
  end

  def flash_messages
    flash.each { |t, m| concat flash_message(t, m) }
  end

  def menu_link(text, path)
    klass = 'menu-link'
    klass += ' current-page' if current_page?(path)

    content_tag :p do
      link_to(text, path, class: klass)
    end
  end

  def icon(name)
    content_tag :i, nil, class: "icon-#{name}"
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

    def flash_message_class(key)
      "flash-message-#{FLASH_MESSSAGE_TYPES[key] || 'primary'}"
    end

    def flash_message(key, message)
      content_tag :div, class: "flash-message #{flash_message_class(key)}" do
        concat message
        concat link_to("\u2716", 'javascript:void(0)', class: 'close-link')
      end
    end
end
