/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
class FlashMessage {
  constructor(elem) {
    this.close = this.close.bind(this);
    this.elem = elem;
    const closeLink = this.elem.querySelector('.close-link');
    if (!closeLink) { return; }
    closeLink.addEventListener('click', () => this.close());
    this.timeout = null;
    this.autoClose();
  }

  close() { return this.elem.classList.add('hide'); }

  // TODO: test on all browsers
  autoClose() {
    this.timeout = window.setTimeout(this.close, 10000);
    return this.elem.addEventListener('mouseenter', () => {
      window.clearTimeout(this.timeout);
      return this.elem.addEventListener('mouseleave', () => {
        return this.timeout = window.setTimeout(this.close, 5000);
      });
    });
  }
}

document.addEventListener('turbolinks:load', () => Array.from(document.querySelectorAll('.flash-message')).map((message) =>
  new FlashMessage(message)));
