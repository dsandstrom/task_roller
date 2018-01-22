class FlashMessage
  constructor: (@elem) ->
    closeLink = @elem.querySelector('.close-link')
    return unless closeLink
    closeLink.addEventListener 'click', => @close()

  close: -> @elem.classList.add('hide')

document.addEventListener 'turbolinks:load', () ->
  for message in document.querySelectorAll('.flash-message')
    new FlashMessage(message)
