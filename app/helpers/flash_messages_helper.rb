# frozen_string_literal: true

module FlashMessagesHelper
  FLASH_MESSSAGE_TYPES = {
    'alert' => 'warning',
    'notice' => 'success',
    'success' => 'success'
  }.freeze

  def flash_messages
    flash.each { |t, m| concat flash_message(t, m) }
  end

  private

    def flash_message_class(key)
      "flash-message-#{FLASH_MESSSAGE_TYPES[key] || 'primary'}"
    end

    def flash_message(key, message)
      content_tag :div, class: "flash-message #{flash_message_class(key)}" do
        content_tag :div, class: 'flash-message-container' do
          concat message
          concat close_link('flash-message-close-link')
        end
      end
    end

    def close_link(extra_class = nil)
      css_class = "close-link #{extra_class}".strip

      link_to("\u2716", 'javascript:void(0)', class: css_class,
                                              title: 'Dismiss')
    end
end
