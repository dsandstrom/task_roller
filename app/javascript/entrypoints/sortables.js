import Sortable from 'sortablejs/Sortable.min.js';
import { patch } from "@rails/request.js";

const sortableClasses = ['categories-and-projects'];

document.addEventListener('turbo:load', function() {
  sortableClasses.forEach((sortableClass) => {
    for (let elem of document.getElementsByClassName(sortableClass)) {
      new Sortable(elem, {
        handle: '.category-name',
        onEnd: rePositionCategory
      })
    }
  });
});

// TODO: don't send if didn't move
function rePositionCategory(event) {
  const { newIndex, item } = event;
  const url = item.dataset["sortableUrl"];

  patch(url, {
    body: JSON.stringify({ category: { new_position: newIndex + 1 } }),
    responseKind: "json"
  });
}
