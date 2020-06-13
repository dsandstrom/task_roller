/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS103: Rewrite code to no longer use __guard__
 * DS205: Consider reworking code to avoid use of IIFEs
 * DS206: Consider reworking classes to avoid initClass
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */

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
      toolbar: ['bold', 'italic', headingTool, '|',
                'quote', 'unordered-list', 'ordered-list', '|',
                'link', 'code', 'strikethrough', '|',
                'preview', 'side-by-side', 'fullscreen', '|',
                'guide']
    };
  }
}

const FormValidator = require("validate-js/validate")

var Form = (function() {
  let displayError = undefined;
  let addClass = undefined;
  let updateMessage = undefined;
  let addNewMessage = undefined;

  Form = class Form {
    static initClass() {

      displayError = function(error) {
        const input = document.getElementById(error.id);
        if (!input) { return; }
        addClass(input);
        return updateMessage(input, error.message);
      };

      addClass = function(input) {
        input.classList.add('error');
        return input.parentNode.classList.add('error');
      };

      updateMessage = function(input, message) {
        const messageClass = 'field-message';
        let elem = input.parentNode.querySelector(`.${messageClass}`);
        if (!elem) { elem = addNewMessage(input, messageClass); }
        return elem.innerHTML = message;
      };

      addNewMessage = function(input, messageClass) {
        const elem = document.createElement('p');
        elem.classList.add(messageClass);
        input.parentNode.appendChild(elem);
        return elem;
      };
    }
    constructor(form, editors) {
      this.afterValidate = this.afterValidate.bind(this);
      this.form = form;
      this.editors = editors;
      this.button = this.form.querySelector("[type='submit']");
      if (!this.button) { return; }
      this.validator = new FormValidator(this.form.name, this.options(), this.afterValidate);
      this.validator.registerCallback('required_with_editor', this.validateEditorRequired)
      this.validator.setMessage('required', 'required');
      this.validator.setMessage('required_with_editor', 'required');
      this.watchInputs();
      this.watchTextareas();
    }

    // check editor below
    // TODO: make invalid if only spaces/tabs
    // TODO: make less dependent on editor logic
    validateEditorRequired(value, param, field) {
      // var validator = this;
      let fieldNode = field.element;
      if (!fieldNode) return false;

      let parentNode = fieldNode.parentNode
      if (!parentNode || !parentNode.classList.contains('field')) return false;

      let editorNode = fieldNode.parentNode.querySelector('.CodeMirror');
      if (!editorNode) return false;

      return !editorNode.classList.contains('CodeMirror-empty');
    }

    options() {
      const objectName = __guard__(this.form.name != null ? this.form.name.match(/^(\w+)_form$/) : undefined, x => x[1]);
      if (!objectName) { return; }
      return [
        {
          name: `${objectName}[name]`,
          display: 'Name',
          rules: 'required'
        },
        {
          name: `${objectName}[email]`,
          display: 'Email',
          rules: 'required|valid_email'
        },
        {
          name: `${objectName}[summary]`,
          display: 'Summary',
          rules: 'required'
        },
        {
          name: `${objectName}[body]`,
          display: 'Body',
          rules: 'callback_required_with_editor'
        },
        {
          name: `${objectName}[description]`,
          display: 'Description',
          rules: 'callback_required_with_editor'
        }
      ];
    }

    watchInputs() {
      const form = this;
      const fields = this.validator.fields
      const values = Object.values(fields)

      values.forEach((field) => {
        const selector = 'input[name="' + field.name + '"]';
        const inputNode = this.form.querySelector(selector);
        if (!inputNode) return;

        inputNode.addEventListener('keyup', (event) => {
          const currentField = fields[event.target.name]
          if (!currentField) return;

          currentField.element = event.target;
          currentField.value = event.target.value;
          currentField.id = event.target.id;
          // clear error for field

          form.validator.errors = form.validator.errors.filter(function (obj) {
            return obj.name !== currentField.name;
          });
          form.validator._validateField(currentField);
          form.afterValidate(form.validator.errors, event);
        })
      });
    }

    watchTextareas() {
      const form = this;
      const fields = form.validator.fields;

      this.editors.forEach((editor) => {

        // https://codemirror.net/doc/manual.html
        editor.editor.codemirror.on("changes", function(codemirror, changes) {
          const textarea = codemirror.getTextArea();
          if (!textarea) return;

          const currentField = fields[textarea.name]
          if (!currentField) return;

          currentField.element = textarea;
          currentField.value = codemirror.doc.getValue();
          currentField.id = textarea.id;
          console.log(currentField);

          // clear error for field
          form.validator.errors = form.validator.errors.filter(function (obj) {
            return obj.name !== currentField.name;
          });
          form.validator._validateField(currentField);
          form.afterValidate(form.validator.errors, event);
        });
      });

    }

    // FIXME: if other fields have errors, fixing the current field doesn't
    // clear the required message
    // maybe clear message of current field only
    clearErrors() {
      this.button.disabled = false;
      for (let error of Array.from(this.form.querySelectorAll('.error'))) {
        error.classList.remove('error');
      }
      const message = this.form.querySelector('.field-message');
      if (message) { return message.classList.add('hide'); }
    }

    afterValidate(errors, event) {
      this.clearErrors();
      if (!errors.length) { return; }
      const message = this.form.querySelector('.field-message');
      if (message) { message.classList.remove('hide'); }
      Array.from(errors).map((error) => displayError(error));
      return true;
    }
  };
  Form.initClass();
  return Form;
})();

function __guard__(value, transform) {
  return (typeof value !== 'undefined' && value !== null) ? transform(value) : undefined;
}

document.addEventListener('turbolinks:load', function() {
  // add markdown editor to textareas
  const editorIds = ['task_description', 'issue_description',
                     'issue_comment_body', 'task_comment_body'];

  const currentEditors = [];
  editorIds.forEach((id, i) => {
    var editorTarget = document.getElementById(id);
    if (!editorTarget || editorTarget.style.display == 'none') return;

    currentEditors.push(new Editor(editorTarget));
  });

  // add validation to forms
  const formNames = ['issue_type_form', 'task_type_form', 'user_form',
                     'issue_form', 'category_form', 'project_form',
                     'task_form', 'task_comment_form', 'issue_comment_form'];
  const currentForms = [];

  for (let form of Array.from(document.querySelectorAll('form'))) {
    if (!formNames.includes(form.name)) { continue; }
    currentForms.push(new Form(form, currentEditors));
  }

  // syntax highlight
  document.querySelectorAll('.comment pre code').forEach((block) => {
    hljs.highlightBlock(block);
  });
});
