class Dropdown {
  constructor(elem) {
    this.dropdown = elem;
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
    const top = this.link.offsetTop;
    const height = this.link.offsetHeight;

    this.dropdown.style.top = `${top + height}px`;
    this.dropdown.classList.toggle('active');
    this.link.classList.toggle('active');
  }

  toggleOff() {
    this.dropdown.classList.remove('active');
    this.link.classList.remove('active');
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
