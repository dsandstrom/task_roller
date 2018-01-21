class Field
  constuctor: (@elem) ->
    @isValid = true

  validate: ->
    # console.log 'validate'
    # console.log @elem
    false
    # console.log @elem
    # @isValid = @elem.value.length > 0

class Form
  constructor: (@id) ->
    @elem = document.getElementById(@id)
    return unless @elem
    @fields = []
    for required in document.querySelectorAll('[required="required"]')
      field = new Field(required)
      @fields.push(field)
    return unless @fields.length

    @isValid = true
    @watchSubmit()

  watchSubmit: ->
    @elem.addEventListener 'submit', (event) =>
      return event.preventDefault() unless @valid()
      true

  valid: ->
    for required in document.querySelectorAll('[required="required"]')
      isValid = required.value.length > 0
      @isValid = false unless isValid
    @isValid

document.addEventListener 'turbolinks:load', () ->
  new Form('user-form')
