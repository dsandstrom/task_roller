class FooterToggle {
  constructor(elem) {
    this.elem = elem;

    this.watchContainer();
  }

  static clickIgnoreList = ['A', 'BUTTON', 'INPUT'];

  watchContainer() {
    this.elem.addEventListener('click', this.showFooter);
  }

  stopWatchingComment() {
    this.elem.removeEventListener('click', this.showFooter)
  }

  static ignoreClick(target) {
    return FooterToggle.clickIgnoreList.includes(target.tagName) ||
           FooterToggle.clickIgnoreList.includes(target.parentNode.tagName);
  }

  showFooter(event) {
    if (FooterToggle.ignoreClick(event.target)) return;

    this.classList.remove('hide-footer');

    const currentContainer = containers.find((c) => c.elem.id == this.id)
    if (!currentContainer) return;

    currentContainer.stopWatchingComment();
  }
}

var containers = [];

document.addEventListener('turbo:load', function() {
  for (var elem of document.querySelectorAll('.comment.hide-footer')) {
    containers.push(new FooterToggle(elem));
  }

  for (var elem of document.querySelectorAll('.issue.hide-footer')) {
    containers.push(new FooterToggle(elem));
  }

  for (var elem of document.querySelectorAll('.task.hide-footer')) {
    containers.push(new FooterToggle(elem));
  }
});

// new comment added
document.addEventListener('turbo:after-stream-render', function(event) {
  for (var elem of document.querySelectorAll('.comment.hide-footer')) {
    if(containers.find((c) => c.elem.id == elem.id)) continue;

    containers.push(new FooterToggle(elem));
  }

  for (var elem of document.querySelectorAll('.issue.hide-footer')) {
    containers.push(new FooterToggle(elem));
  }

  for (var elem of document.querySelectorAll('.task.hide-footer')) {
    containers.push(new FooterToggle(elem));
  }
});
