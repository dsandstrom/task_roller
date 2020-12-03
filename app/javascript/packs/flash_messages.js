class FlashMessage {
  constructor(elem) {
    this.close = this.close.bind(this);
    this.elem = elem;

    const closeLink = this.elem.querySelector('.close-link');
    if (!closeLink) return;

    closeLink.addEventListener('click', () => this.close());
    this.timeout = null;
    this.autoClose();
    this.watchScroll();
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

  // message is static initially, but absolute on scroll
  // static allows the message to show up even if scrolled down the page,
  // absolute allows you to scroll away from the message so it's not annoying
  // becomes static-like when scrolling up and sticks to the top of the page
  // TODO: make smoother when scrolling up (maybe set back to static)
  watchScroll() {
    let top = this.elem.style.top || null;

    document.addEventListener('scroll', function(event) {
      // TODO: use querySelectorAll
      // multiple messages not really supported by the css anyways
      const currentElem = event.target.querySelector('.flash-message');
      if (!currentElem) return;

      if (top === null || top > window.pageYOffset) {
        top = window.pageYOffset

        currentElem.style.position = 'absolute';
        currentElem.style.top = top + 'px';
      }
    });
  }
}

document.addEventListener('turbolinks:load', function() {
  for (var message of document.querySelectorAll('.flash-message')) {
    new FlashMessage(message);
  }
})
