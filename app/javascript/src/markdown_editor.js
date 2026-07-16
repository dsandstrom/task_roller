import EasyMDE from 'easymde/dist/easymde.min.js';
import hljs from 'highlight.js';

// pick languages to import for highlight.js instead of all
// https://bjacobel.com/2016/12/04/highlight-bundle-size/
//
// import hljs from 'highlight.js/lib/highlight';
//
// ['javascript', 'python', 'bash'].forEach((langName) => {
//   // Using require() here because import() support hasn't landed in Webpack
//   // yet
//   const langModule = require(`highlight.js/lib/languages/${langName}`);
//   hljs.registerLanguage(langName, langModule);
// });
// to exclude from pack (not sure where to add)
// module.exports = {
//   ...
//   plugins: [
//     ...
//     new webpack.ContextReplacementPlugin(
//       /highlight\.js\/lib\/languages$/,
//       new RegExp(`^./(${['javascript', 'python', 'bash'].join('|')})$`),
//     ),
//   ],
//   ...
// }

export class MarkdownEditor {
  constructor(elem) {
    this.elem = elem;
    this.editor = new EasyMDE(this.options());
    return this.editor;
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
