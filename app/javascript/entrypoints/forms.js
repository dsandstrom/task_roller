import {Form} from './../src/form';
import {HiddenForm} from './../src/hidden_form';
import hljs from 'highlight.js';

let currentForms = [];
const formNames = ['issue_type_form', 'task_type_form', 'user_form',
                   'issue_form', 'category_form', 'project_form',
                   'task_form', 'task_comment_form', 'issue_comment_form',
                   'user_password_form'];
let hiddenForms = new Map();
hiddenForms.set('task_assignment_link', 'task_assignment_form');

// const resetCommentForms = function (event) {
//   let openComments = document.querySelectorAll('.comment.with-form');
//
//   for (var i = 0; i < openComments.length; i++) {
//     let openComment = openComments[i];
//
//     openComment.classList.remove('with-form');
//     openComment.classList.add('with-hidden-form');
//   }
// }

// const initForms = function (event) {
//   formNames.forEach((name, i) => {
//     document.getElementsByName(name).forEach((element) => {
//       let form = currentForm(element);
//
//       if (form) {
//         form.focus();
//       } else {
//         form = new Form(element);
//
//         currentForms.push(form);
//         element.classList.add('with-validation');
//         form.focus();
//       }
//     });
//   });
// }

const initFormsTurbo = function (event) {
  formNames.forEach((name, i) => {
    document.getElementsByName(name).forEach((element) => {
      let form = new Form(element);
      element.classList.add('with-validation');
      form.focus();
    });
  });
}

// const currentForm = function (element) {
//   return currentForms.find(form => form.form == element);
// }

// NOTE: not sure if needed
const syntaxHighlight = function (event) {
  // syntax highlight
  for (var block of document.querySelectorAll('.comment pre code')) {
    hljs.highlightElement(block);
  }
}

// document.addEventListener('turbo:click', function(event) {
//   console.log('turbo click');
//
//   // resetCommentForms();
// });

document.addEventListener('turbo:load', function(event) {
  // console.log('turbo load');
  initFormsTurbo(event);
  syntaxHighlight();

  // toggle hidden sidebar forms
  for (let [linkId, formId] of hiddenForms) {
    const linkElem = document.getElementById(linkId);
    const formElem = document.getElementById(formId);
    if (!linkElem || !formElem) return;

    new HiddenForm(linkElem, formElem);
  }
});

// After markdown editor is added
document.addEventListener('turbo:frame-load', function(event) {
  // console.log('turbo frame load');
  // let eventTarget = event.target;
  // if (eventTarget.id != 'turbo_new_comment') return;

  let eventComment = event.target.parentNode;

  if (!eventComment.classList.contains('comment')) return;

  if (eventComment.classList.contains('with-form')) {
    // After reset
    eventComment.classList.remove('with-form');
  } else {
    // After edit
    eventComment.classList.add('with-form');
    initFormsTurbo(event);
  }

  // resetCommentForms(event);
  // syntaxHighlight();

  // TODO: if form added, toggle off other forms
});

// After comment create
document.addEventListener('turbo:before-stream-render', function(event) {
  // console.log('turbo');

  let newComment = document.getElementById('new_comment');
  if (!newComment) return;

  newComment.classList.remove('with-form');
});

// document.addEventListener('turbo:visit', function() {
//   var openComments = document.querySelectorAll('.comment.with-form');
//
//   for (var i = 0; i < openComments.length; i++) {
//     var openComment = openComments[i];
//     var id = openComment.dataset.id;
//
//     if (id) {
//       openComment.classList.remove('with-form');
//       openComment.classList.add('with-hidden-form');
//     }
//   }
// })
