class Dropdown {
  constructor(elem) {
    this.dropdown = elem;
    this.activeClass = 'active';
    const linkSelector = elem.dataset.link;
    this.link = document.querySelector(`.${linkSelector}`);
    if (!this.valid()) {
      return;
    }

    this.watchLink();
  }

  valid() {
    return !!this.link;
  }

  dropdownElem(elem) {
    return (elem &&
            (elem.classList.contains('dropdown-menu') ||
             elem.classList.contains('dropdown-link'))) ||
            (elem.parentNode &&
             elem.parentNode.classList.contains('dropdown-menu'));
  }

  watchLink() {
    const dropdown = this;

    this.link.addEventListener('click', function(event) {
      event.preventDefault();
      dropdown.toggle();
    })

    document.addEventListener('click', function(event) {
      const target = event.target;
      if (!dropdown.dropdownElem(target)) {
        dropdown.toggleOff();
      }
    })
  }

  toggle() {
    this.dropdown.style.top = this.positionTop();
    this.dropdown.style.right = this.positionRight();
    this.dropdown.classList.toggle(this.activeClass);
    this.link.classList.toggle(this.activeClass);
  }

  toggleOff() {
    this.dropdown.classList.remove(this.activeClass);
    this.link.classList.remove(this.activeClass);
  }

  positionTop() {
    const top = this.link.offsetTop;
    const height = this.link.offsetHeight;
    return `${top + height}px`;
  }

  positionRight() {
    const left = this.link.offsetLeft;
    const width = this.link.offsetWidth;
    const windowWidth = window.innerWidth;
    return `${windowWidth - (left + width)}px`;
  }
}

var dropdowns = [];
document.addEventListener('turbolinks:load', function() {
  for (var elem of document.querySelectorAll('.dropdown-menu')) {
    dropdowns.push(new Dropdown(elem));
  }
})
// close any current dropdowns
document.addEventListener('turbolinks:visit', function() {
  for (var dropdown of dropdowns) {
    dropdown.toggleOff();
  }
  dropdowns = [];
})
