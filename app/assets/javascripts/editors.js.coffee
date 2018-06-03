# FIXME: rc requires code block to have emtpy line above
# FIXME: simple editor fork - ordered list -> unordered list
# simplemde.min.self-.js?body=1:9 Uncaught SyntaxError: Invalid regular
#   expression: /*/: Nothing to repeat
#     at new RegExp (<anonymous>)
#     at c (simplemde.min.self-.js?body=1:9)
#     at simplemde.min.self-.js?body=1:9
#     at O (simplemde.min.self-.js?body=1:9)
#     at Object.b [as action] (simplemde.min.self-.js?body=1:9)
#     at HTMLButtonElement.e.action.function.e.action.t.onclick
#       (simplemde.min.self-.js?body=1:9)
# orig version doesn't auto number, switch between unordered -> ordered

SimpleMDE::renderPreview = (previewTarget) ->
  editor = this
  if previewTarget == false
    # stop rendering preview
    editor.previewElement = null
  if typeof previewTarget == 'object' and previewTarget.nodeType == 1
    # remember new preview target
    editor.previewElement = previewTarget
  if !editor.previewElement
    return
  # SimpleMDE.patchHTML editor.previewElement,
  #   editor.options.previewRender(editor.value())
  editor.previewElement.innerHTML = editor.options.previewRender(editor.value())
  Rainbow.color()

class Editor
  constructor: (@elem) ->
    options = {
      element: @elem
      autoDownloadFontAwesome: false
      autofocus: false
      autosave: false
      blockStyles: {
        bold: '**'
        italic: '_'
      }
      placeholder: 'Start typing here...'
      promptURLs: false
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
  # syntax highlight
  Rainbow.color() if document.querySelector('.comment')

  taskDescription = document.getElementById('task_description')
  if taskDescription
    new Editor(taskDescription)
