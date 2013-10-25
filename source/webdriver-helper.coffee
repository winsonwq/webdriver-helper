webdriver = require 'selenium-webdriver'
WebDriver = webdriver.WebDriver

_ = require 'underscore'
mr = require 'Mr.Async'
urlHelper = require 'url'

class Elements extends Array

  constructor: (@wdElements) ->
    @initialized = false

  count: (countHandler) ->
    return @.length if @initialized
    @init (elems) => countHandler?.call @, elems.length

  init: (initHandler) ->
    return @ if @initialized
    @wdElements.then (elems) =>
      @initialized = true
      @.push(elem) for elem in elems

      initHandler?.call @, @
  
  get: (index, getHandler) ->
    index = 0 if index is undefined
    return @[index] if @initialized

    @init (elems) => getHandler.call @, elems[index]

_click = webdriver.WebElement.prototype.click
_isSelected = webdriver.WebElement.prototype.isSelected
_isEnabled = webdriver.WebElement.prototype.isEnabled
_.extend webdriver.WebElement.prototype,

  text: (textHandler) ->
    @getText().then proxy @, textHandler

  html: (htmlHandler) ->
    @getInnerHtml().then proxy @, htmlHandler

  click: (clickHandler) ->
    _click.call(@).then proxy @, clickHandler

  enter: (text, enterHandler) ->
    @sendKeys(text).then proxy @, enterHandler

  check: () -> @isSelected (checked) => @click() unless checked

  uncheck: () -> @isSelected (checked) => @click() if checked

  select: () -> @isSelected (checked) => @click() unless checked

  isSelected: (valHandler) ->
    _isSelected.call(@).then proxy @, valHandler
    @

  isChecked: (valHandler) ->
    _isSelected.call(@).then proxy @, valHandler
    @

  isEnabled: (valHandler) ->
    _isEnabled.call(@).then proxy @, valHandler

  value: (valHandler) ->
    @attr 'value', proxy @, valHandler

  attr: (attrName, attrHandler) ->
    @getAttribute(attrName).then proxy @, attrHandler

  css: (cssName, valueHandler) ->
    @getCssValue(cssName).then proxy @, valueHandler

  # for multi-select dropdownlist
  values: (valuesHandler) ->
    values = []
    that = @
    @findElements(webdriver.By.tagName('option')).then (options) ->

      mr.asynEach(options, ((option) ->
        iterator = this
        option.isSelected (selected) ->
          if selected
            option.value (optValue) -> 
              values.push optValue
              iterator.next()
          else iterator.next()
      ), -> 
        valuesHandler.call that, values
      ).start()

  option: (values...) ->
    targetOptions = []
    @findElements(webdriver.By.tagName('option')).then (options) ->

      mr.asynEach(options, ((option) ->
        option.getAttribute('value').then this.callback (optValue) -> 
          targetOptions.push(option) if _.contains values, optValue
      ), -> 
        _.each targetOptions, (option) ->
          option.click()
      ).start()

_.extend WebDriver.Window.prototype, {
  position: (x, y) ->
    if typeof x is 'function'
      @getPosition().then (position) =>
        x.call @, position.x, position.y
    else 
      @setPosition x, y

  size: (width, height) ->
    if typeof width is 'function'
      @getSize().then (size) =>
        width.call @, size.width, size.height
    else 
      @setSize width, height
}

class Alert

  constructor: (@wdAlert) -> 

  text: (textHandler) -> @wdAlert.getText().then proxy @, textHandler

  accept: (thenHandler) -> @wdAlert.accept().then proxy @, thenHandler

  dismiss: (thenHandler) -> @wdAlert.dismiss().then proxy @, thenHandler

  enter: (text, thenHandler) -> @wdAlert.sendKeys(text).then proxy @, thenHandler

proxy = (context, handler) ->
  -> handler?.apply context, arguments

partialLinkTextFormula = /\:contains\([\'\"](.+)[\'\"]\)/

_.extend WebDriver.prototype, {

  dialog: () -> new Alert(@switchTo().alert())

  window: () -> @manage().window()

  elements: (selector) -> new Elements @findElements(webdriver.By.css(selector))

  element: (selector) -> @findElement(webdriver.By.css(selector))

  input: (selector) -> @element selector

  link: (selector) ->
    partialText = ''
    selector.replace partialLinkTextFormula, (matched, partial) -> partialText = partial
    return @element selector if partialText is ''
    @findElement webdriver.By.partialLinkText partialText

  dropdownlist: (selector) -> @element selector

  sleep: (duration) -> this.sleep duration

  navigateTo: (url) -> 
    @currentUrl (currUrl) =>
      @.get urlHelper.resolve currUrl, url

  refresh: -> @navigate().refresh()

  back: -> @navigate().back()

  forward: -> @navigate().forward()

  title: (titleHandler) -> @getTitle().then proxy @, titleHandler

  currentUrl: (parsedUrlHandler) ->
    @getCurrentUrl().then (currUrl) =>
      parsedUrlHandler?.call @, currUrl, urlHelper.parse(currUrl)
}