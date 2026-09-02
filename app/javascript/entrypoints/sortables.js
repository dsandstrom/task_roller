import Sortable from 'sortablejs/Sortable.min.js';
import { patch } from "@rails/request.js";

const sortableProjects = 'sortable-projects';

document.addEventListener('turbo:load', function() {
  const categories = document.getElementById('sortable-categories');
  const issueTypes = document.getElementById('sortable-issue-types');
  const taskTypes = document.getElementById('sortable-task-types');

  if (categories) {
    new Sortable(categories, {
      onEnd: rePositionCategory
    })
  }

  for (let elem of document.getElementsByClassName(sortableProjects)) {
    new Sortable(elem, {
      onEnd: rePositionProject
    })
  }

  if (issueTypes) {
    new Sortable(issueTypes, {
      onEnd: rePositionIssueType
    })
  }

  if (taskTypes) {
    new Sortable(taskTypes, {
      onEnd: rePositionTaskType
    })
  }
});

function rePosition(event, paramKey) {
  const { oldIndex, newIndex, item } = event;
  const url = item.dataset["sortableUrl"];

  if (oldIndex == newIndex) return;

  let params = {};
  params[paramKey] = { new_position: newIndex + 1 };

  patch(url, {
    body: JSON.stringify(params),
    responseKind: "json"
  });
}

function rePositionCategory(event) {
  rePosition(event, 'category')
}

function rePositionProject(event) {
  rePosition(event, 'project')
}

function rePositionIssueType(event) {
  rePosition(event, 'issue_type')
}

function rePositionTaskType(event) {
  rePosition(event, 'task_type')
}
