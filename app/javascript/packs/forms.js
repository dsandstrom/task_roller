import {MarkdownEditor} from 'src/markdown_editor';
import {Form} from 'src/form';
import {HiddenForm} from 'src/hidden_form';
import hljs from 'highlight.js';

let currentEditors = [];
const editorNames = ['issue_comment[body]', 'issue[description]',
                     'task_comment[body]', 'task[description]'];
const formNames = ['issue_type_form', 'task_type_form', 'user_form',
                   'issue_form', 'category_form', 'project_form',
                   'task_form', 'task_comment_form', 'issue_comment_form',
                   'user_password_form'];
let hiddenForms = new Map();
hiddenForms.set('task_assignment_link', 'task_assignment_form');

const initMarkdownEditors = function (event) {
  editorNames.forEach((name, i) => {
    document.getElementsByName(name).forEach((element) => {
      if (!element.classList.contains('with-editor')) {
        currentEditors.push(new MarkdownEditor(element));
        element.classList.add('with-editor');
      }
    });
  });
}

document.addEventListener('turbolinks:load', function(event) {
  initMarkdownEditors(event);

  // add validation to forms
  for (let form of document.querySelectorAll('form')) {
    if (!formNames.includes(form.name)) continue;

    new Form(form, currentEditors);
  }

  // syntax highlight
  for (var block of document.querySelectorAll('.comment pre code')) {
    hljs.highlightBlock(block);
  }

  // toggle hidden sidebar forms
  for (let [linkId, formId] of hiddenForms) {
    const linkElem = document.getElementById(linkId);
    const formElem = document.getElementById(formId);
    if (!linkElem || !formElem) return;

    new HiddenForm(linkElem, formElem);
  }
});

document.addEventListener('custom:reset-forms', function(event) {
  initMarkdownEditors(event);
});

document.addEventListener('turbolinks:visit', function() {
  var openComments = document.querySelectorAll('.comment.with-form');

  for (var i = 0; i < openComments.length; i++) {
    var openComment = openComments[i];
    var id = openComment.dataset.id;

    if (id) {
      openComment.classList.remove('with-form');
      openComment.classList.add('with-hidden-form');
    }
  }
})
