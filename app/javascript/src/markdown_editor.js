// FIXME: redcarpet requires code block to have emtpy line above
// TODO: comment forms - hide toolbar and shorten unless focused once

import EasyMDE from 'easymde/dist/easymde.min.js';
import hljs from 'highlight.js';

export {hljs} from 'highlight.js';

export class MarkdownEditor {
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
