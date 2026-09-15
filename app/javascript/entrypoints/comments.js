class CommentFooterToggle {
  constructor(elem) {
    this.elem = elem;

    this.watchComment();
  }

  watchComment() {
    this.elem.addEventListener('click', this.showCommentFooter);
  }

  stopWatchingComment() {
    this.elem.removeEventListener('click', this.showCommentFooter)
  }

  showCommentFooter(event) {
    this.classList.remove('hide-footer');

    const currentComment = comments.find((c) => c.elem.id == this.id)
    if (!currentComment) return;

    currentComment.stopWatchingComment();
  }
}

var comments = [];

document.addEventListener('turbo:load', function() {
  for (var elem of document.querySelectorAll('.comment.hide-footer')) {
    comments.push(new CommentFooterToggle(elem));
  }
});

// new comment added
document.addEventListener('turbo:after-stream-render', function(event) {
  for (var elem of document.querySelectorAll('.comment.hide-footer')) {
    if(comments.find((c) => c.elem.id == elem.id)) continue;

    comments.push(new CommentFooterToggle(elem));
  }
});
