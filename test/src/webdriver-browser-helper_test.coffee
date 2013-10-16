webdriver = require 'selenium-webdriver'
builder = require './webdriver-builder'
require('chai').should()
require('../../lib/webdriver-helper')

describe 'webdriver browser helper', ->

  driver = null
  host = 'http://localhost:9001'

  before -> driver = builder.build()
  beforeEach -> driver.get host
  after -> driver.quit()

  describe 'navigateTo', ->

    it 'could redirect to target absolute url', (done) ->
      driver.navigateTo '/demo.html'
      driver.element('body').text (text) ->
        text.should.contain 'this is a demo page !'
        done()

    it 'could redirect to target relative url', (done) ->
      driver.navigateTo 'demo.html'
      driver.element('body').text (text) ->
        text.should.contain 'this is a demo page !'
        done()

