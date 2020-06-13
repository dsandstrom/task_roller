import FormValidator from 'validate-js/validate';

export class Form {
  constructor(elem, editors = []) {
    this.afterValidate = this.afterValidate.bind(this);
    this.form = elem;
    this.editors = editors;
    this.button = this.form.querySelector("[type='submit']");
    if (!this.button) return;

    this.validator = this.initValidator();
    this.watchInputs();
    this.watchEditors();
  }

  initValidator() {
    const validator = new FormValidator(this.form.name, this.options(), this.afterValidate);

    validator.registerCallback('required_with_editor', this.validateEditorRequired)
    validator.setMessage('required', 'required');
    validator.setMessage('required_with_editor', 'required');
    return validator;
  }

  displayError(error) {
    const input = document.getElementById(error.id);
    if (!input) return;

    this.addClass(input);
    this.updateMessage(input, error.message);
  }

  // used by displayError
  addClass(input) {
    input.classList.add('error');
    input.parentNode.classList.add('error');
  }

  // used by displayError
  updateMessage(input, message) {
    const messageClass = 'field-message';
    let elem = input.parentNode.querySelector(`.${messageClass}`);

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
    input.parentNode.appendChild(elem);
    return elem;
  }

  // when a textarea with a markdown editor, use editor's value
  // TODO: make invalid if only spaces/tabs
  // TODO: make less dependent on editor logic
  validateEditorRequired(value, param, field) {
    let fieldNode = field.element;
    if (!fieldNode) return false;

    let parentNode = fieldNode.parentNode
    if (!parentNode || !parentNode.classList.contains('field')) return false;

    let editorNode = fieldNode.parentNode.querySelector('.CodeMirror');
    if (!editorNode) return false;

    return !editorNode.classList.contains('CodeMirror-empty');
  }

  options() {
    const matches = this.form.name.match(/^(\w+)_form$/);
    if (!matches) return;

    const currentName = matches[1];
    if (!currentName) return;

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

        const currentInput = event.target;
        currentField.element = currentInput;
        currentField.value = currentInput.value;
        currentField.id = currentInput.id;

        // clear error for field
        form.validator.errors = form.validator.errors.filter(function (obj) {
          return obj.name !== currentField.name;
        });
        form.validator._validateField(currentField);

        const newErrors = form.validator.errors.filter(function (obj) {
          return obj.name === currentField.name;
        });
        if (newErrors.length === 0) {
          for (let message of currentInput.parentNode.querySelectorAll('.field-message')) {
            message.classList.add('hide');
          }
        }

        form.afterValidate(form.validator.errors, event);
      })
    });
  }

  watchEditors() {
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

        // clear errors for field
        form.validator.errors = form.validator.errors.filter(function (obj) {
          return obj.name !== currentField.name;
        });
        form.validator._validateField(currentField);

        const newErrors = form.validator.errors.filter(function (obj) {
          return obj.name === currentField.name;
        });
        if (newErrors.length === 0) {
          for (let message of textarea.parentNode.querySelectorAll('.field-message')) {
            message.classList.add('hide');
          }
        }

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

  afterValidate(errors, _event) {
    this.clearErrors();
    if (!errors.length) return;

    for (let error of errors) {
      this.displayError(error);
    }
    return true;
  }
};