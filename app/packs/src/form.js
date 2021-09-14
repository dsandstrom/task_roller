// https://github.com/rickharrison/validate.js
import FormValidator from 'validate-js/validate';
import {MarkdownEditor} from 'src/markdown_editor';

// https://production.task-roller.net/issues/17

export class Form {
  constructor(elem) {
    this.editorNames = ['issue_comment[body]', 'issue[description]',
                        'task_comment[body]', 'task[description]'];
    this.editors = [];
    this.form = elem;
    this.button = this.form.querySelector("[type='submit']");
    if (!this.button) return;

    this.afterValidate = this.afterValidate.bind(this);
    this.initEditors()
    this.validator = this.initValidator();
    this.fields = this.validator.fields;
    this.watchInputs();
    this.watchEditors();
  }

  currentEditor(element) {
    return this.editors.find(e => e.element == element);
  }

  initValidator() {
    const validator = new FormValidator(this.form.name, this.options(), this.afterValidate);

    validator.registerCallback('required_with_editor', this.validateTextarea)
    validator.setMessage('required', 'required');
    validator.setMessage('required_with_editor', 'required');
    return validator;
  }

  inputField(input) {
    var field = input.parentNode;
    if (field.classList.contains('field')) {
      return field;
    }
    return field.parentNode;
  }

  displayError(error) {
    const input = document.getElementById(error.id);
    if (!input) return;

    const field = this.inputField(input);
    this.addClass(input, field);
    this.updateMessage(input, field, error.message);
  }

  // used by displayError
  addClass(input, field) {
    input.classList.add('error');
    field.classList.add('error');
  }

  // used by displayError
  updateMessage(input, field, message) {
    const messageClass = 'field-message';
    let elem = field.querySelector(`.${messageClass}`);

    if (!elem) {
      elem = this.addNewMessage(input, messageClass);
    }
    elem.innerHTML = message;
    elem.classList.remove('hide');
  }

  // used by displayError
  addNewMessage(input, messageClass) {
    const elem = document.createElement('p');

    elem.classList.add(messageClass);
    this.inputField(input).appendChild(elem);;
    return elem;
  }

  validateTextarea(value, _param, field) {
    const matches = value.match(/[^\s\t]+/);
    return matches != null;
  }

  options() {
    const matches = this.form.name.match(/^(\w+)_form$/);
    if (!matches) return;

    var currentName = matches[1];
    if (!currentName) return;

    if (currentName == 'user_password') {
      currentName = 'user';
    }

    return [
      {
        name: `${currentName}[name]`,
        display: 'Name',
        rules: 'required'
      },
      {
        name: `${currentName}[email]`,
        display: 'Email',
        rules: 'required|valid_email'
      },
      {
        name: `${currentName}[summary]`,
        display: 'Summary',
        rules: 'required'
      },
      {
        name: `${currentName}[password]`,
        display: 'Password',
        rules: 'required'
      },
      {
        name: `${currentName}[password_confirmation]`,
        display: 'Confirmation',
        rules: `required|matches[${currentName}[password]]`
      },
      {
        name: `${currentName}[current_password]`,
        display: 'Current password',
        rules: 'required'
      },
      {
        name: `${currentName}[body]`,
        display: 'Body',
        rules: 'callback_required_with_editor'
      },
      {
        name: `${currentName}[description]`,
        display: 'Description',
        rules: 'callback_required_with_editor'
      }
    ];
  }

  validateField(input, value) {
    if (!input) return;

    const field = this.fields[input.name]
    if (!field) return;

    field.element = input;
    field.value = value;
    field.id = input.id;

    // clear error for field
    this.validator.errors = this.validator.errors.filter(function (obj) {
      return obj.name !== field.name;
    });
    this.validator._validateField(field);

    const newErrors = this.validator.errors.filter(function (obj) {
      return obj.name === field.name;
    });
    if (newErrors.length === 0) {
      for (let message of field.element.parentNode.querySelectorAll('.field-message')) {
        message.classList.add('hide');
      }
    }
  }

  watchInputs() {
    const form = this;
    const values = Object.values(form.fields)

    values.forEach((field) => {
      const selector = 'input[name="' + field.name + '"]';
      const inputNode = this.form.querySelector(selector);
      if (!inputNode) return;

      inputNode.addEventListener('keyup', (event) => {
        form.validateField(event.target, event.target.value);
        form.afterValidate(form.validator.errors, event);
      })
    });
  }

  initEditors() {
    const form = this.form;
    this.editorNames.forEach((name, i) => {
      form.querySelectorAll('[name="' + name + '"]').forEach((element) => {
        const editor = new MarkdownEditor(element);

        this.editors.push(editor);
        element.classList.add('with-editor');
        if (element.dataset.autofocus == 'true') {
          editor.codemirror.focus();
        }
      });
    });
  }

  watchEditors() {
    const form = this;

    this.editors.forEach((editor) => {
      // https://codemirror.net/doc/manual.html
      editor.codemirror.on("changes", function(codemirror, changes) {
        form.validateField(codemirror.getTextArea(), codemirror.doc.getValue());
        form.afterValidate(form.validator.errors, codemirror);
      });
    });
  }

  clearErrors() {
    this.button.disabled = false;
    for (let error of this.form.querySelectorAll('.error')) {
      error.classList.remove('error');
    }
  }

  afterValidate(errors, event) {
    this.clearErrors();
    if (!errors.length) return true;

    for (let error of errors) {
      this.displayError(error);
    }
    if (event.type == 'submit') {
      event.stopImmediatePropagation();
    }
    return false;
  }

  focus() {
    this.editors.forEach((editor, i) => {
      editor.codemirror.focus();
    });
  }
};
