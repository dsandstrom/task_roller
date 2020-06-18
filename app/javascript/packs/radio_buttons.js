/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * DS205: Consider reworking code to avoid use of IIFEs
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
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
      return this.elem.classList.add('active');
    } else {
      this.elem.classList.add('disabled');
      return this.elem.classList.remove('active');
    }
  }
}

class RadioButtons {
  constructor(elem) {
    this.labels = [];
    for (let label of Array.from(elem.querySelectorAll('label'))) {
      this.labels.push(new RadioButtonLabel(label));
    }
    if (!this.labels.length) { return; }
    this.watchForChanges();
  }

  watchForChanges() {
    return (() => {
      const result = [];
      for (let label of Array.from(this.labels)) {
        const radio = label.elem.querySelector('input');
        if (!radio) { next; }
        result.push(radio.addEventListener('change', () => {
          return this.toggleDisabledClasses();
        }));
      }
      return result;
    })();
  }

  toggleDisabledClasses() {
    return Array.from(this.labels).map((label) =>
      label.toggleDisabledClass());
  }
}

document.addEventListener('turbolinks:load', function() {
  const radioButtonIds = ['issue_type_color_labels', 'issue_type_icon_labels',
                          'task_type_color_labels', 'task_type_icon_labels',
                          'issue_issue_type_labels', 'task_task_type_labels',
                          'issue_status_labels', 'issue_open_tasks_labels',
                          'issue_order_labels'];
  return (() => {
    const result = [];
    for (let id of Array.from(radioButtonIds)) {
      const labels = document.getElementById(id);
      if (labels) { result.push(new RadioButtons(labels)); } else {
        result.push(undefined);
      }
    }
    return result;
  })();
});
