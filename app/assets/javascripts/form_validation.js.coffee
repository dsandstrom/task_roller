class Form
  constructor: (@form) ->
    @button = @form.querySelector("[type='submit']")
    return unless @button
    @validator = new FormValidator(@form.name, @options(), @afterValidate)
    @validator.setMessage('required', 'required')
    @watchInputs()
    @watchTextareas()

  options: ->
    objectName = @form.name?.match(/^(\w+)_form$/)?[1]
    return unless objectName
    [
      {
        name: "#{objectName}[name]"
        display: 'Name'
        rules: 'required'
      },
      {
        name: "#{objectName}[email]"
        display: 'Email'
        rules: 'required|valid_email'
      }
      {
        name: "#{objectName}[summary]"
        display: 'Summary'
        rules: 'required'
      },
      {
        name: "#{objectName}[description]"
        display: 'Description'
        rules: 'required'
      }
    ]

  watchInputs: ->
    for input in @form.querySelectorAll("input[type='text']")
      input.addEventListener 'keyup', =>
        # TODO: validate field instead
        @validator._validateForm()

  watchTextareas: ->
    for textarea in @form.querySelectorAll('textarea')
      textarea.addEventListener 'keyup', =>
        # TODO: validate field instead
        @validator._validateForm()

  clearErrors: ->
    @button.disabled = false
    for error in @form.querySelectorAll('.error')
      error.classList.remove('error')
    message = @form.querySelector('.field-message')
    message.classList.add('hide') if message

  afterValidate: (errors, event) =>
    @clearErrors()
    return unless errors.length
    message = @form.querySelector('.field-message')
    message.classList.remove('hide') if message
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
    messageClass = 'field-message'
    elem = input.parentNode.querySelector(".#{messageClass}")
    elem = addNewMessage(input, messageClass) unless elem
    elem.innerHTML = message

  addNewMessage = (input, messageClass) ->
    elem = document.createElement('p')
    elem.classList.add(messageClass)
    input.parentNode.appendChild(elem)
    elem

document.addEventListener 'turbolinks:load', () ->
  formNames = ['issue_type_form', 'task_type_form', 'user_form', 'issue_form',
               'category_form', 'project_form']
  for form in document.querySelectorAll('form')
    continue unless formNames.includes(form.name)
    new Form(form)
