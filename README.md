# webdriver-helper

This helper library offer lots of friendly api while using JavaScript WebDriver

## Getting Started
Install the module with: `npm install webdriver-helper` to enable the friendly APIs.

## Documentation

You could setup the selenium webdriver like this. Remember to require 'webdriver-helper' to enable friendly apis.

```js
var webdriver = require('selenium-webdriver');
require('chai').should();
// enable the friendly apis by requiring 'webdriver-helper'
require('webdriver-helper'); 

var builder = new webdriver.Builder().
  usingServer('http://localhost:4444/wd/hub').
  withCapabilities({
    browserName: 'firefox' 
  });
var browser = builder.build();
browser.get('http://localhost:9001');
```
### Browser API

#### browser.navigateTo()
Go to the path which is relative to current path.

```js
browser.navigateTo('/demo.html?a=1&b=2#c=1');
browser.currentUrl(function(currUrl, url) {
  currUrl.should.equal('http://localhost:9001/demo.html?a=1&b=2#c=1')
});
```

#### browser.currentUrl(currHandler)
Get current url.

```js
browser.navigateTo('/demo.html?a=1&b=2#c=1');
browser.currentUrl(function(currUrl, url) {
  currUrl.should.equal('http://localhost:9001/demo.html?a=1&b=2#c=1');
  url.protocol.should.equal('http:');
  url.slashes.should.equal(true);
  url.host.should.equal('localhost:9001');
  url.port.should.equal('9001');
  url.hostname.should.equal('localhost');
  url.href.should.equal('http://localhost:9001/demo.html?a=1&b=2#c=1');
  url.hash.should.equal('#c=1');
  url.search.should.equal('?a=1&b=2');
  url.query.should.equal('a=1&b=2');
  url.pathname.should.equal('/demo.html');
  url.path.should.equal('/demo.html?a=1&b=2');
});
```
#### browser.refresh()
Refresh current page.

#### browser.forward()
Go forward to next page in history.

#### browser.back()
Go back to privious page in history.

#### browser.title(titleHandler)
Get title in current page.

```js
browser.title(function (title) {
  title.should.equal('your title');
});
```

### Window API

#### browser.window()
Get current window.

#### browser.window().position(positionHandler)
Get current window's position.
```js
browser.window().position(function (x, y) {
  x.should.equal(0);
  y.should.equal(0);
});
```

#### browser.window().position(x, y)
Set current window's position to (x, y) relative to screen.
```js
browser.window().position(100, 100);
```

#### browser.window().size(sizeHandler)
Get current window's size.
```js
browser.window().size(function (width, height) {
  width.should.equal(500);
  height.should.equal(500);
});
```

#### browser.window().size(width, height)
Set current window's size with `width` and `height`.

```js
browser.window().size(500, 500)
```

#### browser.window().maximize()
Maximize the current window to full screen.

### Element API

#### browser.element(selector)
Get first matched element by selector.

#### browser.element(selector).click()
Click the element, the `click` method is also used for `browser.input()` and `browser.dropdownlist()` element.

#### browser.element(selector).value(valueHandler)
Get value for the the matched element's value attribute. It could used in `browser.input(selector).value()` as well.

```js
browser.element('input#name').value(function (val) {
  val.should.equal('your name');
});
```
#### browser.element(selector).text(textHandler)
Get the innerText of the matched element.

```js
browser.element('body').text(function (text) {
  text.should.contain('hello world!');
});
```

#### browser.element(selector).html(htmlHandler)
Get the innerHTML of the matched element.

```js
browser.element('body').html(function (html) {
  html.should.contain('<p>hello world!</p>');
});
```

#### browser.element(selector).isEnabled(enabledHandler)
Get value for the matched element's status.

```js
browser.element('input#btn').isEnabled(function (enabledStatus) {
  enabledStatus.should.be.false;
});
```

#### browser.input(selector)
Get first matched `input` element by selector, it includes textbox, checkbox, radio etc...

#### browser.input(selector).enter(text)
Enter text into matched textbox.

#### browser.dropdownlist(selector)
Get first matched `select` element by selector.

## Contributing
In lieu of a formal styleguide, take care to maintain the existing coding style. Add unit tests for any new or changed functionality. Lint and test your code using [Grunt](http://gruntjs.com/).

## Release History
_(Nothing yet)_

## License
Copyright (c) 2013 Wang Qiu  
Licensed under the MIT license.
