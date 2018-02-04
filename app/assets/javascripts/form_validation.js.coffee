class Form
  constructor: (@name, @options = {}) ->
    @form = document.querySelector("[name='#{@name}']")
    return unless @form
    @button = @form.querySelector("[type='submit']")
    return unless @button
    @validator = new FormValidator(@name, @options, @afterValidate)
    @watchInputs()

  watchInputs: ->
    for input in @form.querySelectorAll("input[type='text']")
      input.addEventListener 'keyup', =>
        @validator._validateForm()

  clearErrors: ->
    @button.disabled = false
    for error in @form.querySelectorAll('.error')
      error.classList.remove('error')

  afterValidate: (errors, event) =>
    @clearErrors()
    return unless errors.length
    for error in errors
      displayError(error)

  displayError = (error) ->
    input = document.getElementById(error.id)
    return unless input
    addClass(input)
    updateMessage(input, error.message)

  addClass = (input) ->
    input.classList.add('error')
    input.parentNode.classList.add('error')

  updateMessage = (input, message) ->
    messageClass = 'field-error-message'
    elem = input.parentNode.querySelector(".#{messageClass}")
    elem = addNewMessage(input, messageClass) unless elem
    elem.innerHTML = message

  addNewMessage = (input, messageClass) ->
    elem = document.createElement('p')
    elem.classList.add(messageClass)
    input.parentNode.appendChild(elem)
    elem

class RollerTypeForm

  constructor: () ->

document.addEventListener 'turbolinks:load', () ->
  validationOptions = [
    {name: 'issue_type[name]', display: 'Name', rules: 'required'},
    {name: 'task_type[name]', display: 'Name', rules: 'required'},
    {name: 'user[email]', display: 'Email', rules: 'required|valid_email'},
    {name: 'user[name]', display: 'Name', rules: 'required'},
  ]

  for formName in ['issue_type_form', 'task_type_form', 'user_form']
    new Form(formName, validationOptions)