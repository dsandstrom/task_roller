/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
// FIXME: redcarpet requires code block to have emtpy line above

const EasyMDE = require('easymde/dist/easymde.min.js')

const simplyPromise = value => new Promise((resolve, reject) => resolve(value));

const startHightlighting = function(html) {
  let promises = [];
  const htmlParts = html.split(/<\/?pre>/g);
  promises = htmlParts.map(function(value, index) {
    if (/^<code/.test(value)) {
      const matches = value.match(/^<code class="lang-(\w+)"/);
      const language = (matches != null ? matches.length : undefined) ? matches[1] : 'generic';
      value = value.replace(/^<code[^>]*>|<\/code>$/g, '');
      value = unescapeHtml(value);
      return new Promise((resolve, reject) => Rainbow.color(
        value,
        language,
        function(highlighted, l) {
          let codeClass = "prettyprint rainbow";
          if (l) { codeClass += ` lang-${l}`; }
          return resolve(
            `<pre><code class=\"${codeClass}\">${highlighted}</code></pre>`
          );
      }));
    } else {
      return simplyPromise(value);
    }
  });
  return Promise.all(promises);
};

var unescapeHtml = value => value
  .replace(/&#39;/g, "'")
  .replace(/&quot;/g, '"')
  .replace(/&lt;/g, '<')
  .replace(/&gt;/g, '>')
  .replace(/&amp;/g, '&');

// TODO: On IE, replace innerHTML and run Rainbow.color()
// instead of using patchHTML
// FIXME: not updating both fullscreen preview and split screen preview
EasyMDE.prototype.renderPreview = function(previewTarget) {
  const editor = this;
  // stop rendering preview
  if (previewTarget === false) { editor.previewElement = null; }
  if ((typeof previewTarget === 'object') && (previewTarget.nodeType === 1)) {
    // remember new preview target
    editor.previewElement = previewTarget;
  }
  if (!editor.previewElement) { return; }
  const html = editor.options.previewRender(editor.value());
  // startHightlighting(html).then (htmlParts) ->
  //   # TODO: don't need expose both attributes, just need html
  //   editor.patchHTML(editor.previewElement, htmlParts.join(''))
  return true;
};

class Editor {
  constructor(elem) {
    this.elem = elem;
    this.editor = new EasyMDE(this.options());
    this.editTitles();
  }

  options() {
    return {
      element: this.elem,
      autoDownloadFontAwesome: false,
      autofocus: false,
      // autosave: false
      blockStyles: {
        bold: '**',
        italic: '_'
      },
      placeholder: 'Start typing here...',
      promptURLs: false,
      status: false,
      toolbar: ['bold', 'italic', 'code', '|',
                'heading-1', 'strikethrough', 'link', '|',
                'quote', 'unordered-list', 'ordered-list', '|',
                'fullscreen', 'side-by-side', 'preview']
    };
  }

  editTitles() {
    let changes;
    return changes = { 'Big Heading': 'Big Heading', 'Heading': 'Heading' };
  }
}
    // TODO: change heading

// use turbolinks:load event instead
// Rainbow.defer = true

document.addEventListener('turbolinks:load', function() {
  // syntax highlight
  // Rainbow.color() if document.querySelector('.comment pre code')

  const taskDescription = document.getElementById('task_description');
  if (taskDescription) {
    return new Editor(taskDescription);
  }
});
