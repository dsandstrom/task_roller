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

simplyPromise = (value) ->
  new Promise((resolve, reject) -> resolve(value))

startHightlighting = (html) ->
  promises = []
  htmlParts = html.split(/<\/?pre>/g)
  promises = htmlParts.map (value, index) ->
    if /^<code/.test(value)
      matches = value.match(/^<code class="lang-(\w+)"/)
      language = matches[1] if matches?.length
      if language
        value = value.replace(/^<code[^>]*>|<\/code>$/g, '')
        new Promise (resolve, reject) ->
          Rainbow.color(
            value,
            language,
            (highlighted, l) ->
              codeClass = "prettyprint rainbow"
              codeClass += " lang-#{l}" if l
              resolve(
                "<pre><code class=\"#{codeClass}\">#{highlighted}</code></pre>"
              )
          )
      else
        simplyPromise("<pre>#{value}</pre>")
    else
      simplyPromise(value)
  Promise.all(promises)

# TODO: On IE, replace innerHTML and run Rainbow.color()
# instead of using patchHTML
SimpleMDE::renderPreview = (previewTarget) ->
  editor = this
  # stop rendering preview
  editor.previewElement = null if previewTarget == false
  if typeof previewTarget == 'object' and previewTarget.nodeType == 1
    # remember new preview target
    editor.previewElement = previewTarget
  return unless editor.previewElement
  html = editor.options.previewRender(editor.value())
  startHightlighting(html).then (htmlParts) ->
    editor.patchHTML(editor.previewElement, htmlParts.join(''))
  editor

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
                'fullscreen', 'side-by-side', 'preview', '|',
                'guide']
    }
    @editor = new SimpleMDE(options)
    @editTitles()

  editTitles: ->
    changes = { 'Big Heading', 'Heading' }
    # TODO: change heading


# use turbolinks:load event instead
Rainbow.defer = true

document.addEventListener 'turbolinks:load', () ->
  # syntax highlight
  Rainbow.color() if document.querySelector('.comment pre code')

  taskDescription = document.getElementById('task_description')
  if taskDescription
    new Editor(taskDescription)
