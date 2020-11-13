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
      css_class = 'close-link flash-message-close-link'

      content_tag :div, class: "flash-message #{flash_message_class(key)}" do
        content_tag :div, class: 'flash-message-container' do
          concat message
          concat link_to("\u2716", 'javascript:void(0)', class: css_class)
        end
      end
    end
end
