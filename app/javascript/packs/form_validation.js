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

// TODO: validate editors
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
      this.validator.setMessage('required', 'required');
      this.watchInputs();
      this.watchTextareas();
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
          rules: 'required'
        },
        {
          name: `${objectName}[description]`,
          display: 'Description',
          rules: 'required'
        }
      ];
    }

    watchInputs() {
      return Array.from(this.form.querySelectorAll("input[type='text']")).map((input) =>
        input.addEventListener('keyup', () => {
          // TODO: validate field instead
          return this.validator._validateForm();
        }));
    }

    watchTextareas() {
      return Array.from(this.form.querySelectorAll('textarea')).map((textarea) =>
        textarea.addEventListener('keyup', () => {
          // TODO: validate field instead
          return this.validator._validateForm();
        }));
    }

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
      return Array.from(errors).map((error) => displayError(error));
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
