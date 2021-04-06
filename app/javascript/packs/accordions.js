class Accordion {
  constructor(elem) {
    this.elem = elem;
    this.links = elem.querySelectorAll('.accordion-menu a');
    this.contents = elem.querySelectorAll('.accordion-contents > *');
    if (!this.links.length) return;

    this.watchLinks();
  }

  watchLinks() {
    let accordion = this;

    this.links.forEach((link) => {
      link.addEventListener('click', function (event) {
        let currentLink = event.target;
        if (event.target.tagName != 'A') {
          currentLink = currentLink.parentNode;
        }
        let contentName = currentLink.dataset.contentName;
        if (!contentName) return;

        let content = accordion.elem.querySelector('[name="' + contentName + '"]');
        if (!content) return;

        accordion.activate(currentLink, content)
      })
    });
  }

  activate(link, content) {
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
