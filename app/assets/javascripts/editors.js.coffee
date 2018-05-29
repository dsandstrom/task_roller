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
      previewRender: previewRender
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

  # https://github.com/sparksuite/simplemde-markdown-editor/issues/138
  previewRender = (plainText, preview) ->
    editor = this.parent
    setTimeout ->
      preview.innerHTML = editor.markdown(plainText)
      Rainbow.color()
    , 1
    "Loading..."

document.addEventListener 'turbolinks:load', () ->
  # syntax highlight
  Rainbow.color()

  taskDescription = document.getElementById('task_description')
  if taskDescription
    new Editor(taskDescription)
