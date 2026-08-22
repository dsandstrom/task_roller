class TaskFormSync {
  constructor(fullForm, projectForm) {
    this.fullForm = fullForm;
    this.projectForm = projectForm;
  }

  submitHandler(event) {
    this.syncTextInputs();
    this.syncRadioInputs();
    this.syncMultiSelects();
    this.syncTextareas();

    return true;
  }

  watchForSubmit() {
    this.projectForm.addEventListener('submit', this.submitHandler.bind(this));
  }

  reset() {
    this.projectForm.removeEventListener('submit', this.submitHandler);
  }

  syncTextInputs() {
    for (var input of this.fullForm.querySelectorAll('input[type=text]')) {
      let origInput = input;
      let matchingInput = this.projectForm[origInput.name];

      if (!matchingInput) continue;

      matchingInput.value = origInput.value;
    };
  }

  syncTextareas() {
    for (var input of this.fullForm.querySelectorAll('textarea')) {
      let origInput = input;
      let matchingInput = this.projectForm[origInput.name];

      if (!matchingInput) continue;

      matchingInput.value = origInput.value;
    };
  }

  syncRadioInputs() {
    for (var input of this.fullForm.querySelectorAll('input[type=radio]')) {
      var origInput = input;
      var matchingInput = this.projectForm[origInput.name];

      if (!matchingInput) continue;

      if (origInput.checked) {
        matchingInput.value = origInput.value;
      }
    };
  }

  syncMultiSelects() {
    for (var input of this.fullForm.querySelectorAll('select[multiple]')) {
      let allSelected = [];
      let origInput = input;
      let matchingInput = this.projectForm[origInput.name];

      if (!matchingInput) continue;

      for(var selected of origInput.selectedOptions)  {
        allSelected.push(selected.value);
      };

      matchingInput.value = allSelected;
    };
  }
}

let taskFormSync = null;

function setupFormSync() {
  const fullTaskForm = document.getElementById('task_full_form');
  const projectTaskForm = document.getElementById('task_project_form');

  if (!fullTaskForm || !projectTaskForm) return;

  taskFormSync = new TaskFormSync(fullTaskForm, projectTaskForm);
  taskFormSync.watchForSubmit();
}

document.addEventListener('turbo:load', function() {
  setupFormSync();
});

document.addEventListener('turbo:after-stream-render', function(event) {
  if(taskFormSync) {
    taskFormSync.reset();
    taskFormSync = null;
  }

  setupFormSync();
});
