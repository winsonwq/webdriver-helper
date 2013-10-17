webdriver = require 'selenium-webdriver'
builder = require './webdriver-builder'
require('chai').should()
require('../../lib/webdriver-helper')

describe 'webdriver window helper', ->

  browser = null
  currentWindow = null
  host = 'http://localhost:9001'

  before -> browser = builder.build()

  beforeEach -> 
    browser.get host
    currentWindow = browser.window()

  after -> browser.quit()

  describe '#position', ->

    it 'could set the position of current window', (done) ->
      currentWindow.position 500, 500
      currentWindow.wdWindow.getPosition().then (position) ->
        position.x.should.equal 500
        position.y.should.equal 500
        done()

    it 'could get the position of current window', (done) ->
      currentWindow.position 500, 500
      currentWindow.position (x, y) ->
        x.should.equal 500
        y.should.equal 500
        done()
      