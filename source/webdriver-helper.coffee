webdriver = require 'selenium-webdriver'
_ = require 'underscore'

class Element

  constructor: (@wdElement) ->
  enter: (text) ->
    @wdElement.sendKeys text

_.extend webdriver.WebDriver.prototype, 
  
  element: (selector) ->
    new Element this.findElement(webdriver.By.css(selector))

  input: (selector) ->
    this.element selector