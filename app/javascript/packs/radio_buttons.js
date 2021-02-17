class RadioButtonLabel {
  constructor(elem) {
    this.elem = elem;
    this.radio = this.elem.querySelector('input');
    this.elem.classList.add('roller-radio-button-label');
    this.toggleDisabledClass();
  }

  checked() { return this.radio.checked; }

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

class RadioButtons {
  constructor(elem) {
    this.labels = [];
    for (var label of elem.querySelectorAll('label')) {
      this.labels.push(new RadioButtonLabel(label));
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

const radioButtonIds = ['issue_type_color_labels', 'issue_type_icon_labels',
                        'task_type_color_labels', 'task_type_icon_labels',
                        'issue_issue_type_labels', 'task_task_type_labels',
                        'issue_status_labels', 'issue_open_tasks_labels',
                        'issue_order_labels', 'task_status_labels',
                        'task_order_labels', 'issue_type_labels',
                        'task_type_labels'];

document.addEventListener('turbolinks:load', function() {
  for (let id of radioButtonIds) {
    const labels = document.getElementById(id);
    if (!labels) continue;

    new RadioButtons(labels);
  }
});
