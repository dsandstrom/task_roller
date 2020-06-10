// FIXME: redcarpet requires code block to have emtpy line above
// TODO: comment forms - hide toolbar and shorten unless focused once

const EasyMDE = require('easymde/dist/easymde.min.js')
const hljs = require('highlight.js')

class Editor {
  constructor(elem) {
    this.elem = elem;
    this.editor = new EasyMDE(this.options());
  }

  options() {
    // just want one heading version (h1, h2, h3 are all the same size)
    // so button should toggle h1, but look like a generic Heading
    var headingTool = {
      name: 'heading-1',
      action: EasyMDE.toggleHeading1,
      className: "fa fa-header",
      title: 'Heading'
    }
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
                headingTool, 'strikethrough', 'link', '|',
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

  const editorIds = ['task_description', 'issue_description',
                     'issue_comment_body', 'task_comment_body'];
  editorIds.forEach((id, i) => {
    var editorTarget = document.getElementById(id);
    if (!editorTarget || editorTarget.style.display == 'none') return;

    new Editor(editorTarget);
  });
});
