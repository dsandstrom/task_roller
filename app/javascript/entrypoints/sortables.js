import Sortable from 'sortablejs/Sortable.min.js';
import { patch } from "@rails/request.js";

const sortableCategories = 'categories-and-projects';
const sortableProjects = 'category-projects-list';

document.addEventListener('turbo:load', function() {
  for (let elem of document.getElementsByClassName(sortableCategories)) {
    new Sortable(elem, {
      handle: '.category-name',
      onEnd: rePositionCategory
    })
  }

  for (let elem of document.getElementsByClassName(sortableProjects)) {
    new Sortable(elem, {
      onEnd: rePositionProject
    })
  }
});

function rePositionCategory(event) {
  const { oldIndex, newIndex, item } = event;
  const url = item.dataset["sortableUrl"];

  if (oldIndex == newIndex) return;

  patch(url, {
    body: JSON.stringify({ category: { new_position: newIndex + 1 } }),
    responseKind: "json"
  });
}

function rePositionProject(event) {
  const { oldIndex, newIndex, item } = event;
  const url = item.dataset["sortableUrl"];

  if (oldIndex == newIndex) return;

  patch(url, {
    body: JSON.stringify({ project: { new_position: newIndex + 1 } }),
    responseKind: "json"
  });
}
