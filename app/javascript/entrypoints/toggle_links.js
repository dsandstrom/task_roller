class ToggleLink {
  constructor(elem) {
    this.elem = elem;
    this.toggleTarget = document.getElementById(elem.dataset.toggleTarget);
    if (!this.toggleTarget) return;

    this.watchLink();
  }

  watchLink() {
    let link = this;

    link.elem.addEventListener('click', function (event) {
      link.toggleTarget.classList.remove('hide');
      link.elem.classList.add('disabled');
      event.stopPropagation();
    })
  }
}

var toggleLinks = [];

document.addEventListener('turbo:load', function() {
  for (var elem of document.querySelectorAll('.toggle-link')) {
    toggleLinks.push(new ToggleLink(elem));
  }
});
