import {MarkdownEditor} from 'src/markdown_editor';
import hljs from 'highlight.js';
import {Form} from 'src/form';

document.addEventListener('turbolinks:load', function() {
  // add markdown editor to textareas
  const editorIds = ['task_description', 'issue_description',
                     'issue_comment_body', 'task_comment_body'];
  const currentEditors = [];

  editorIds.forEach((id, i) => {
    var editorTarget = document.getElementById(id);
    if (!editorTarget || editorTarget.style.display == 'none') return;

    currentEditors.push(new MarkdownEditor(editorTarget));
  });

  // add validation to forms
  const formNames = ['issue_type_form', 'task_type_form', 'user_form',
                     'issue_form', 'category_form', 'project_form',
                     'task_form', 'task_comment_form', 'issue_comment_form'];
  const currentForms = [];

  for (let form of document.querySelectorAll('form')) {
    if (!formNames.includes(form.name)) continue;

    currentForms.push(new Form(form, currentEditors));
  }

  // syntax highlight
  for (var block of document.querySelectorAll('.comment pre code')) {
    hljs.highlightBlock(block);
  }
});
