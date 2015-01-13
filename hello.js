var page = require('webpage').create();
page.open("http://9gag.tv/?ref=9nav", function () {
  for (var i = 0; i < 200; i++){
    page.sendEvent("keypress", page.event.key.Space, [null, null, 0]);
  }
  console.log(page.content);
  phantom.exit()
})