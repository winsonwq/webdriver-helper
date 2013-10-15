webdriver = require 'selenium-webdriver'
WebDriver = webdriver.WebDriver
_ = require 'underscore'
mr = require 'Mr.Async'

class Element

  constructor: (@wdElement) ->

  text: (textHandler) ->
    @wdElement.getText().then @proxy(textHandler)

  click: (clickHandler) ->
    @wdElement.click().then @proxy(clickHandler)

  enter: (text) ->
    @wdElement.sendKeys text

  check: () ->
    @isChecked (checked) => @click() unless checked

  uncheck: () ->
    @isChecked (checked) => @click() if checked

  select: Element.prototype.check

  isSelected: (valHandler) ->
    @wdElement.isSelected().then @proxy(valHandler)
    @

  isChecked: Element.prototype.isSelected

  value: (valHandler) ->
    @wdElement.getAttribute('value').then @proxy(valHandler)

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
    -> handler && handler.apply that, arguments

_.extend WebDriver.prototype, {
  
  element: (selector) ->
    new Element this.findElement(webdriver.By.css(selector))

  input: (selector) -> this.element selector
  dropdownlist: (selector) -> this.element selector

}