// FIXME: redcarpet requires code block to have emtpy line above

const EasyMDE = require('easymde/dist/easymde.min.js')
const hljs = require('highlight.js')

class Editor {
  constructor(elem) {
    this.elem = elem;
    this.editor = new EasyMDE(this.options());
  }

  options() {
    return {
      autoDownloadFontAwesome: false,
      autofocus: false,
      autosave: {
        enabled: false
      },
      blockStyles: {
        bold: '**',
        italic: '_'
      },
      element: this.elem,
      placeholder: 'Start typing here...',
      promptURLs: false,
      status: false,
      renderingConfig: {
        codeSyntaxHighlighting: true,
        hljs: hljs
      },
      toolbar: ['bold', 'italic', 'code', '|',
                'heading-1', 'strikethrough', 'link', '|',
                'quote', 'unordered-list', 'ordered-list', '|',
                'fullscreen', 'side-by-side', 'preview']
    };
  }
}

document.addEventListener('turbolinks:load', function() {
  // syntax highlight
  document.querySelectorAll('.comment pre code').forEach((block) => {
    hljs.highlightBlock(block);
  });

  const editorIds = ['task_description', 'issue_description']
  editorIds.forEach((id, i) => {
    var description = document.getElementById(id);

    if (description) {
      new Editor(description);
    }
  });
});
