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

#### browser.navigateTo(path)
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

### Elements API

#### browser.elements(selector)
Get all matched element by selector. every element could use the friendly api listed below.

#### browser.elements(selector).count(coundHandler)
Get count of all matched elements.

```js
browser.elements('input').count(function (count) {
  count.should.equal(6);
});
```

#### browser.elements(selector).get(index, elemHandler)
Get the element in matched elements according to index.

```js
browser.elements('input').get(0, function (elem) {
  elem.enter('hello world!');
  // elem.click();
});
```

#### browser.elements(selector).initialized
Get the status that all elements is initialized or not.

#### browser.elements(selector).init(initedHandler)
Initialize all elements and save inside. In initedHandler, `initialized` property will be updated to `true`. And you could change asyn-invoking to sync-invoking. For example,

```js
browser.elements('input').init(function (elems) {
  this.initialized.should.be.true;
  this.count().should.equal(6);
  this.get(0).enter('hello world');
  this.get(1).attr('name').should.equal('textbox');
  /\* ... \*/
});
```

#### browser.element(selector)
Get first matched element by selector.

#### browser.element(selector).click()
Click the element, the `click` method is also used for `browser.input()`, `browser.dropdownlist()` and `browser.link()` element.

#### browser.element(selector).value(valueHandler)
Get value for the the matched element's value attribute. It could used in `browser.input(selector).value()` as well.

```js
browser.element('input#name').value(function (val) {
  val.should.equal('your name');
});
```

#### browser.element(selector).attr(attrName, attrHandler)
Get value of the matched element's attrubute with attribute name `attrName`.

```js
browser.element('input[name="textbox"]').attr('name', function (attr) {
  attr.should.equal('textbox');
});
```

#### browser.element(selector).css(propertyName, valueHandler)
Get css value of the matched element's css property with name `propertyName`.

```js
browser.element('input[name="textbox"]').css('font-family', function (property) {
  property.should.equal('Georgia');
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

#### browser.input(selector).value(valueHandler)
Get value of matched textbox

#### browser.input(selector).check()
Check matched checkbox.

#### browser.input(selector).uncheck()
Uncheck matched checkbox.

#### browser.input(selector).isChecked(checkedHandler)
Get the checked status.

```js
browser.input('input#checkbox').isChecked(function (checked) {
  checked.should.be.true;
})
```

#### browser.input(selector).select()
Select matched radio button.

#### browser.input(selector).isSeleced(selectedHandler)
Get the selected status. Same as `isChecked`.

#### browser.dropdownlist(selector)
Get first matched `select` element by selector.

#### browser.dropdownlist(selector).option(val1/\*, val2 ... \*/)
Select these options with the valus in arguments. If the dropdownlist couldn't be multi-selected, the option with the last value would be selected.

#### browser.dropdownlist(selector).value(valueHandler)
Get the value for matched dropdownlist.

#### browser.dropdownlist(selector).values(valuesHandler)
For the multi-selected dropdownlist, it will return array of values.

```js
browser.dropdownlist(selector).values(function (values) {
  values.should.eql([2, 3]);
});
```

#### browser.link(selector)
Use css selector to find the matched link

#### browser.link(partialLinkText)
*ONLY FOR LINK* 

```js
browser.link(':contains("Partial Link Text")').click()
```

#### browser.exec(script, args, callback)

```js
browser.exec('alert("hello world!");', function() {
  browser.dialog().text(function (text) {
    text.should.equal('hello world!');
  });
});
```

Use args
```js
browser.exec('alert(arguments[0][0]);', ['hello!'], function() {
  browser.dialog().text(function (text) {
    text.should.equal('hello!');
  });
});
```

Use elements
```js
browser.exec('alert(arguments[0][0].name);', browser.elements('input[type="checkbox"]');
browser.dialog().text(function (text) {
  text.should.equal('checkbox');
});
```

#### browser.execAsync(script, args, callback)

```js
browser.manage().timeouts().setScriptTimeout(5000);
browser.execAsync('var callback = arguments[arguments.length - 1];setTimeout(function(){ callback(10); }, 500);', function(num) {
  num.should.equal(10);
});
```

Use args
```js
browser.manage().timeouts().setScriptTimeout(5000);
browser.execAsync('var callback = arguments[arguments.length - 1];var str = arguments[0][0]; setTimeout(function(){ callback(str); }, 500);', ['hello world'], function(str) {
  str.should.equal('hello world');
});
```

Use elements
```js
browser.manage().timeouts().setScriptTimeout(5000);
browser.execAsync('var callback = arguments[arguments.length - 1];var elem = arguments[0][0]; setTimeout(function(){ callback(elem); }, 500);', browser.elements('input[type="checkbox"]'), function(element) {
  element.attr('name', function(name) {
    name.should.equal('checkbox');
  });
});
```

### Alert API

#### browser.dialog()
Get the dialog which could be alert, confirm, prompt dialog.

#### browser.dialog().text(textHandler)
Get the text on the dialog.

#### browser.dialog().accept(thenHandler)
Accept(Ok) the confirm and prompt dialog.

#### browser.dialog().dismiss(thenHandler)
Dismiss(Cancel) the alert, confirm and prompt dialog.

#### browser.dialog().enter(text, thenHandler)
Enter text in prompt dialog.

## Contributing
In lieu of a formal styleguide, take care to maintain the existing coding style. Add unit tests for any new or changed functionality. Lint and test your code using [Grunt](http://gruntjs.com/).

## Release History
*0.2.0* 2013-10-20 Add dialog behaviors
*0.1.0* 2013-10-17 MVP

## License
Copyright (c) 2013 Wang Qiu  
Licensed under the MIT license.
