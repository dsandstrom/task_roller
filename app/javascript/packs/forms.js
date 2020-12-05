import {MarkdownEditor} from 'src/markdown_editor';
import {Form} from 'src/form';
import {HiddenForm} from 'src/hidden_form';
import hljs from 'highlight.js';

let currentEditors = [];
const editorIds = ['task_description', 'issue_description',
                   'issue_comment_body', 'task_comment_body'];
const formNames = ['issue_type_form', 'task_type_form', 'user_form',
                   'issue_form', 'category_form', 'project_form',
                   'task_form', 'task_comment_form', 'issue_comment_form',
                   'user_password_form'];
let hiddenForms = new Map();
hiddenForms.set('task_assignment_link', 'task_assignment_form');

document.addEventListener('turbolinks:load', function() {
  // add markdown editor to textareas
  editorIds.forEach((id, i) => {
    var editorTarget = document.getElementById(id);
    if (!editorTarget || editorTarget.style.display == 'none') return;

    currentEditors.push(new MarkdownEditor(editorTarget));
  });

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
