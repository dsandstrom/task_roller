// task_assign_link

export class HiddenForm {
  constructor(linkElem, formElem) {
    this.linkElem = linkElem;
    this.formElem = formElem;
    if (!this.linkElem || !this.formElem) return;

    this.cssClass = 'hidden-form';
    this.originalText = linkElem.innerHTML;
    this.hideFormText = 'nevermind, hide the form';

    this.watchLink();
  }

  watchLink() {
    const hiddenForm = this;

    this.linkElem.addEventListener('click', function(event) {
      event.preventDefault();
      hiddenForm.toggleForm();
    })
  }

  toggleForm() {
    if (this.formVisible()) {
      this.hideForm();
    } else {
      this.showForm();
    }
  }

  formVisible() {
    return !this.formElem.classList.contains(this.cssClass);
  }

  hideForm() {
    this.formElem.classList.add(this.cssClass);
    this.linkElem.innerHTML = this.originalText;
  }

  showForm() {
    this.formElem.classList.remove(this.cssClass);
    this.linkElem.innerHTML = this.hideFormText;
  }
}
