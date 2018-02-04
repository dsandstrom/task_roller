class RadioButtonLabel
  constructor: (@elem) ->
    @radio = @elem.querySelector('input')
    @elem.classList.add('roller-radio-button-label')
    @toggleDisabledClass()

  checked: -> @radio.checked

  toggleDisabledClass: ->
    if @checked()
      @elem.classList.remove('disabled')
      @elem.classList.add('active')
    else
      @elem.classList.add('disabled')
      @elem.classList.remove('active')

class RadioButtons
  constructor: (elem) ->
    @labels = []
    for label in elem.querySelectorAll('label')
      @labels.push(new RadioButtonLabel(label))
    return unless @labels.length
    @watchForChanges()

  watchForChanges: ->
    for label in @labels
      radio = label.elem.querySelector('input')
      next unless radio
      radio.addEventListener 'change', =>
        console.log 'change'
        @toggleDisabledClasses()

  toggleDisabledClasses: ->
    for label in @labels
      label.toggleDisabledClass()

document.addEventListener 'turbolinks:load', () ->
  radioButtonIds = ['issue_type_color_labels', 'issue_type_icon_labels',
                    'task_type_color_labels', 'task_type_icon_labels',
                    'issue_issue_type_labels']
  for id in radioButtonIds
    labels = document.getElementById(id)
    new RadioButtons(labels) if labels
