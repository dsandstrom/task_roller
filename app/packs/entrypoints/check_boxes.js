class CheckBoxLabel {
  constructor(elem) {
    this.elem = elem;
    this.checkBox = this.elem.querySelector('input');
    this.elem.classList.add('radio-button-label');
    this.toggleDisabledClass();
  }

  checked() { return this.checkBox.checked; }

  toggleDisabledClass() {
    if (this.checked()) {
      this.elem.classList.remove('disabled');
      this.elem.classList.add('active');
    } else {
      this.elem.classList.add('disabled');
      this.elem.classList.remove('active');
    }
  }
}

class CheckBoxes {
  constructor(elem) {
    this.labels = [];
    for (var label of elem.querySelectorAll('label')) {
      this.labels.push(new CheckBoxLabel(label));
    }
    if (!this.labels.length) return;

    this.watchForChanges();
  }

  watchForChanges() {
    for (var label of this.labels) {
      const radio = label.elem.querySelector('input');
      if (!radio) return;

      radio.addEventListener('change', () => {
        this.toggleDisabledClasses();
      });
    }
  }

  toggleDisabledClasses() {
    for (var label of this.labels) {
      label.toggleDisabledClass();
    }
  }
}

const checkBoxClasses = ['check-box-buttons'];

document.addEventListener('turbolinks:load', function() {
  for (let klass of checkBoxClasses) {
    document.querySelectorAll('.' + klass).forEach((checkBoxes) => {
      new CheckBoxes(checkBoxes);
    });
  }
});
