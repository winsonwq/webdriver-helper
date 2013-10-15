webdriver = require 'selenium-webdriver'
require('chai').should()
webdriverHelper = require('../../lib/webdriver-helper')

specify = it
By = webdriver.By


describe 'webdriver helper', ->

  builder = new webdriver.Builder().usingServer 'http://localhost:4444/wd/hub'
  builder = builder.withCapabilities { browserName: 'firefox' }
  driver = null

  host = 'http://localhost:9001'

  before ->
    driver = builder.build()

  beforeEach ->
    driver.get host

  after ->
    driver.quit()

  describe 'input', ->

    it 'should enter value in textbox', (done) ->
      driver.input('input[name="textbox"]').enter('hello input');
      driver.findElement(By.css('input[name="textbox"]')).getAttribute('value').then (value) ->
        value.should.equal 'hello input'
        done()
