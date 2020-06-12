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
    constructor(form) {
      this.afterValidate = this.afterValidate.bind(this);
      this.form = form;
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
          currentField.element = event.target;
          currentField.value = event.target.value;
          currentField.id = event.target.id;
          // clear error for field
          form.validator.errors = form.validator.errors.filter(function (obj) {
            return obj.name !== currentField.name;
          });
          form.validator._validateField(currentField);
          this.afterValidate(form.validator.errors, event);
        })
      });
    }

    watchTextareas() {
      const form = this;
      const fields = form.validator.fields;

      Array.from(this.form.querySelectorAll('textarea')).map((textarea) =>
        textarea.addEventListener('keyup', (event) => {
          const fieldNode = event.target.parentNode.parentNode.parentNode;
          const inputNode = fieldNode.querySelector('textarea');
          const currentField = fields[inputNode.name];

          currentField.element = inputNode;
          currentField.value = event.target.value;
          currentField.id = inputNode.id;

          // clear error for field
          form.validator.errors = form.validator.errors.filter(function (obj) {
            return obj.name !== currentField.name;
          });
          form.validator._validateField(currentField);
          this.afterValidate(form.validator.errors, event);
        })
      );
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

document.addEventListener('turbolinks:load', function() {
  const formNames = ['issue_type_form', 'task_type_form', 'user_form',
                     'issue_form', 'category_form', 'project_form',
                     'task_form', 'task_comment_form', 'issue_comment_form'];
  return (() => {
    const result = [];
    for (let form of Array.from(document.querySelectorAll('form'))) {
      if (!formNames.includes(form.name)) { continue; }
      result.push(new Form(form));
    }
    return result;
  })();
});

function __guard__(value, transform) {
  return (typeof value !== 'undefined' && value !== null) ? transform(value) : undefined;
}
