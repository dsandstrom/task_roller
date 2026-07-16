class Accordion {
  constructor(elem) {
    this.elem = elem;
    this.links = elem.querySelectorAll('.accordion-menu a');
    this.contents = elem.querySelectorAll('.accordion-contents > *');
    if (!this.links.length) return;
    this.activateFromHash();

    this.watchLinks();
  }

  activateFromHash() {
    let urlHash = window.location.hash;

    if (urlHash) {
      let accordion = this;

      this.links.forEach((link, i) => {
        if (link.hash == urlHash) {
          accordion.activate(link);
          return;
        }
      });
    }
  }

  watchLinks() {
    let accordion = this;

    this.links.forEach((link) => {
      link.addEventListener('click', function (event) {
        let currentLink = event.target;
        if (event.target.tagName != 'A') {
          currentLink = currentLink.parentNode;
        }

        accordion.activate(currentLink);
        event.stopPropagation();
      })
    });
  }

  activate(link) {
    let contentName = link.dataset.contentName;
    if (!contentName) return;

    let content = this.elem.querySelector('[name="' + contentName + '"]');
    if (!content) return;

    this.links.forEach((otherLink, i) => {
      otherLink.classList.remove('active');
    });
    this.contents.forEach((otherContent, i) => {
      otherContent.classList.remove('active');
    });

    link.classList.add('active');
    content.classList.add('active');
  }
}

var accordions = [];
document.addEventListener('turbolinks:load', function() {
  for (var elem of document.querySelectorAll('.accordion')) {
    accordions.push(new Accordion(elem));
  }
})
