class FlashMessage
  constructor: (@elem) ->
    closeLink = @elem.querySelector('.close-link')
    return unless closeLink
    closeLink.addEventListener 'click', => @close()
    @timeout = null
    @autoClose()

  close: => @elem.classList.add('hide')

  # TODO: test on all browsers
  autoClose: ->
    @timeout = window.setTimeout(@close, 10000)
    @elem.addEventListener 'mouseenter', =>
      window.clearTimeout(@timeout)
      @elem.addEventListener 'mouseleave', =>
        @timeout = window.setTimeout(@close, 5000)

document.addEventListener 'turbolinks:load', () ->
  for message in document.querySelectorAll('.flash-message')
    new FlashMessage(message)
