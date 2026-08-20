// https://www.whysthatso.net/today-i-learned/rails-turbo-after-stream-render/
const afterRenderEvent = new Event("turbo:after-stream-render");

addEventListener("turbo:before-stream-render", (event) => {
  const originalRender = event.detail.render

  event.detail.render = function (streamElement) {
    originalRender(streamElement)
    document.dispatchEvent(afterRenderEvent);
  }
})
