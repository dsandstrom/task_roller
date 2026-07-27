class TurboStreamLink {
  constructor(elem) {
    this.elem = elem;

    this.watchLink();
  }

  watchLink() {
    let link = this;

    link.elem.addEventListener('click', function (event) {
      link.elem.classList.add('disabled');
    })
  }
}

var turboStreamLinks = [];

document.addEventListener('turbo:load', function() {
  for (var elem of document.querySelectorAll('.turbo-stream-link')) {
    turboStreamLinks.push(new TurboStreamLink(elem));
  }
});
