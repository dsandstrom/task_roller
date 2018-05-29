# FIXME: rc requires code block to have emtpy line above

class Editor
  constructor: (@elem) ->
    options = {
      element: @elem
      # TODO: replace with own font
      autoDownloadFontAwesome: true
      autofocus: false
      autosave: false
      blockStyles: {
        bold: '**'
        italic: '_'
      }
      placeholder: 'Start typing here...'
      promptURLs: false
      renderingConfig: {
        codeSyntaxHighlighting: true
      }
      showIcons: ['code', 'table']
      status: false
      toolbar: ['bold', 'italic', 'code', '|',
                'heading-1', 'strikethrough', 'link', '|',
                'quote', 'unordered-list', 'ordered-list', '|',
                'preview', 'side-by-side', 'fullscreen', '|',
                'guide']
    }
    @editor = new SimpleMDE(options)
    @editTitles()

  editTitles: ->
    changes = { 'Big Heading', 'Heading' }
    # TODO: change heading




document.addEventListener 'turbolinks:load', () ->
  taskDescription = document.getElementById('task_description')
  if taskDescription
    new Editor(taskDescription)
