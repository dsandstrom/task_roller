import {Form} from './../src/form';
import hljs from 'highlight.js';

let currentForms = [];
const formNames = ['issue_type_form', 'task_type_form', 'user_form',
                   'issue_form', 'category_form', 'project_form',
                   'issue_comment_form', 'task_comment_form',
                   'task_form', 'user_password_form'];

const initForm = function (element) {
  let form = new Form(element);

  element.classList.add('with-validation');
  currentForms.push(form);
  form.focus();
}

const initForms = function (event) {
  formNames.forEach((name, i) => {
    document.getElementsByName(name).forEach((element) => {
      initForm(element);
    });
  });
}

const initTurboForm = function (event) {
  let formElem = event.target.querySelector('form');

  initForm(formElem);
}

const resetCurrentForms = function () {
  currentForms.forEach((form) => {
    form.reset();
  });

  currentForms = [];
}

// NOTE: not sure if needed
const syntaxHighlight = function (event) {
  // syntax highlight
  for (var block of document.querySelectorAll('.comment pre code')) {
    hljs.highlightElement(block);
  }
}

document.addEventListener('turbo:load', function(event) {
  initForms(event);
  syntaxHighlight();
});

// After markdown editor is added
document.addEventListener('turbo:frame-load', function(event) {
  let eventComment = event.target.parentNode;

  if (!eventComment.classList.contains('comment')) return;

  if (eventComment.classList.contains('with-form')) {
    // After reset
    eventComment.classList.remove('with-form');
  } else {
    // After edit
    eventComment.classList.add('with-form');
    initTurboForm(event);
  }
});

// After comment create
document.addEventListener('turbo:before-stream-render', function(event) {
  let newComment = document.getElementById('new_comment');
  if (!newComment) return;

  newComment.classList.remove('with-form');
});

document.addEventListener('turbo:visit', function() {
  // On page leave
  resetCurrentForms();
});
