class SearchTypeLabel {
  constructor(elem) {
    this.elem = elem;
    this.radio = this.elem.querySelector('input');
    this.issueFilters = document.querySelector('.issue-filters');
    this.taskFilters = document.querySelector('.task-filters');
  }

  checked() { return this.radio.checked; }

  toggleTypeFilter() {
    if (!this.radio || !this.checked()) return;

    this.toggle(this.radio.value)
  }

  toggle (value) {
    this.issueFilters.classList.add('hide');
    this.taskFilters.classList.add('hide');

    if (value == 'issues') {
      this.issueFilters.classList.remove('hide');
    } else if (value == 'tasks') {
      this.taskFilters.classList.remove('hide');
    }
  }
}

class SearchTypeLabels {
  constructor(elem) {
    this.labels = [];
    for (var label of elem.querySelectorAll('label')) {
      this.labels.push(new SearchTypeLabel(label));
    }
    if (!this.labels.length) return;

    this.watchForChanges();
  }

  watchForChanges() {
    for (var label of this.labels) {
      const radio = label.elem.querySelector('input');
      if (!radio) return;

      radio.addEventListener('change', () => {
        this.toggleTypeFilters();
      });
    }
  }

  toggleTypeFilters() {
    for (var label of this.labels) {
      label.toggleTypeFilter();
    }
  }
}

const typeLabelIds = ['search_type_labels'];

document.addEventListener('turbolinks:load', function() {
  for (let id of typeLabelIds) {
    const elem = document.getElementById(id);
    if (!elem) continue;

    new SearchTypeLabels(elem);
  }
});
