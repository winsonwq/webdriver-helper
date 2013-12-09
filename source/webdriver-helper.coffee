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

[_click, _isSelected, _isEnabled, _isDisplayed] = (webdriver.WebElement.prototype[name] for name in ['click', 'isSelected', 'isEnabled', 'isDisplayed'])

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

  isDisplayed: (valHandler) ->
    _isDisplayed.call(@).then proxy @, valHandler

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

  _exec: () ->
    args = _.toArray arguments
    async = args.shift()

    return if args.length < 1
    while arg = args.pop()
      script = arg if _.isString arg
      callback = arg if _.isFunction arg
      callArgs = arg if _.isArray arg
      callArgs = arg.wdElements if arg instanceof Elements

    execute = if async then @executeAsyncScript else @executeScript
    execute.call(@, script, callArgs).then proxy @, callback

  exec: () -> @_exec.apply @, [false].concat _.toArray arguments

  execAsync: () -> @_exec.apply @, [true].concat _.toArray arguments

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