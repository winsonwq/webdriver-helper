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
      @.push(new Element(elem)) for elem in elems

      initHandler?.call @, @
  
  get: (index, getHandler) ->
    index = 0 if index is undefined
    return @[index] if @initialized

    @init (elems) => getHandler.call @, elems[index]

class Element

  constructor: (@wdElement) ->

  text: (textHandler) ->
    @wdElement.getText().then @proxy(textHandler)

  click: (clickHandler) ->
    @wdElement.click().then @proxy(clickHandler)

  enter: (text, enterHandler) ->
    @wdElement.sendKeys(text).then @proxy(enterHandler)

  check: () ->
    @isChecked (checked) => @click() unless checked

  uncheck: () ->
    @isChecked (checked) => @click() if checked

  select: Element.prototype.check

  isSelected: (valHandler) ->
    @wdElement.isSelected().then @proxy valHandler
    @

  isChecked: Element.prototype.isSelected

  isEnabled: (valHandler) ->
    @wdElement.isEnabled().then @proxy valHandler

  value: (valHandler) ->
    @attr 'value', @proxy(valHandler)

  attr: (attrName, attrHandler) ->
    @wdElement.getAttribute(attrName).then @proxy attrHandler

  css: (cssName, valueHandler) ->
    @wdElement.getCssValue(cssName).then @proxy valueHandler

  # for multi-select dropdownlist
  values: (valuesHandler) ->
    values = []
    @wdElement.findElements(webdriver.By.tagName('option')).then (options) ->

      mr.asynEach(options, ((option) ->
        iterator = this
        option.isSelected().then (selected) ->
          if selected
            option.getAttribute('value').then (optValue) -> 
              values.push optValue
              iterator.next()
          else iterator.next()
      ), -> 
        valuesHandler values
      ).start()

  option: (values...) ->
    targetOptions = []
    @wdElement.findElements(webdriver.By.tagName('option')).then (options) ->

      mr.asynEach(options, ((option) ->
        option.getAttribute('value').then this.callback (optValue) -> 
          targetOptions.push(option) if _.contains values, optValue
      ), -> 
        _.each targetOptions, (option) ->
          option.click()
      ).start()

  proxy: (handler) ->
    that = @
    -> handler?.apply that, arguments

_.extend WebDriver.prototype, {
  
  elements: (selector) ->
    new Elements @findElements(webdriver.By.css(selector))

  element: (selector) ->
    new Element @findElement(webdriver.By.css(selector))

  input: (selector) -> @element selector
  dropdownlist: (selector) -> @element selector

  sleep: (duration) -> this.sleep duration

  navigateTo: (url) -> 
    @currentUrl (currUrl) =>
      @.get urlHelper.resolve currUrl, url

  currentUrl: (parsedUrlHandler) ->
    @getCurrentUrl().then (currentUrl) =>
      parsedUrlHandler?.call @, currentUrl
}