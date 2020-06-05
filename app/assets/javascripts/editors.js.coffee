# FIXME: rc requires code block to have emtpy line above

simplyPromise = (value) ->
  new Promise((resolve, reject) -> resolve(value))

startHightlighting = (html) ->
  promises = []
  htmlParts = html.split(/<\/?pre>/g)
  promises = htmlParts.map (value, index) ->
    if /^<code/.test(value)
      matches = value.match(/^<code class="lang-(\w+)"/)
      language = if matches?.length then matches[1] else 'generic'
      value = value.replace(/^<code[^>]*>|<\/code>$/g, '')
      value = unescapeHtml(value)
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
      simplyPromise(value)
  Promise.all(promises)

unescapeHtml = (value) ->
  value
    .replace(/&#39;/g, "'")
    .replace(/&quot;/g, '"')
    .replace(/&lt;/g, '<')
    .replace(/&gt;/g, '>')
    .replace(/&amp;/g, '&')

# TODO: On IE, replace innerHTML and run Rainbow.color()
# instead of using patchHTML
# FIXME: not updating both fullscreen preview and split screen preview
EasyMDE::renderPreview = (previewTarget) ->
  editor = this
  # stop rendering preview
  editor.previewElement = null if previewTarget == false
  if typeof previewTarget == 'object' and previewTarget.nodeType == 1
    # remember new preview target
    editor.previewElement = previewTarget
  return unless editor.previewElement
  html = editor.options.previewRender(editor.value())
  # startHightlighting(html).then (htmlParts) ->
  #   # TODO: don't need expose both attributes, just need html
  #   editor.patchHTML(editor.previewElement, htmlParts.join(''))
  true

class Editor
  constructor: (@elem) ->
    @editor = new EasyMDE(@options())
    @editTitles()

  options: ->
    {
      element: @elem
      autoDownloadFontAwesome: false
      autofocus: false
      # autosave: false
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
                'fullscreen', 'side-by-side', 'preview']
    }

  editTitles: ->
    changes = { 'Big Heading', 'Heading' }
    # TODO: change heading

# use turbolinks:load event instead
# Rainbow.defer = true

document.addEventListener 'turbolinks:load', () ->
  # syntax highlight
  # Rainbow.color() if document.querySelector('.comment pre code')

  taskDescription = document.getElementById('task_description')
  if taskDescription
    new Editor(taskDescription)
