class FlashMessage {
  constructor(elem) {
    this.close = this.close.bind(this);
    this.elem = elem;

    const closeLink = this.elem.querySelector('.close-link');
    if (!closeLink) return;

    closeLink.addEventListener('click', () => this.close());
    this.timeout = null;
    this.autoClose();
  }

  close() {
    this.elem.classList.add('hide');
  }

  // close the flash message after 10 secs, pause while mouse hovered over
  // TODO: test on all browsers
  autoClose() {
    this.timeout = window.setTimeout(this.close, 10000);

    this.elem.addEventListener('mouseenter', () => {
      window.clearTimeout(this.timeout);

      this.elem.addEventListener('mouseleave', () => {
        this.timeout = window.setTimeout(this.close, 5000);
      });
    });
  }
}

document.addEventListener('turbolinks:load', function() {
  for (var message of document.querySelectorAll('.flash-message')) {
    new FlashMessage(message);
  }
})
