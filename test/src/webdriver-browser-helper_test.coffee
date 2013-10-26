webdriver = require 'selenium-webdriver'
builder = require './webdriver-builder'
require('chai').should()
require('../../lib/webdriver-helper')

describe 'webdriver browser helper', ->

  browser = null
  host = 'http://localhost:9001'

  before -> browser = builder.build()
  beforeEach -> browser.get host
  after -> browser.quit()

  describe '#currentUrl', ->

    it 'could return current url', (done) ->
      browser.currentUrl (currUrl) ->
        currUrl.should.equal 'http://localhost:9001/'
        done()

    it 'could return current url object', (done) ->
      browser.navigateTo '/demo.html?a=1&b=2#c=1'
      browser.currentUrl (currUrl, url) ->
        url.protocol.should.equal 'http:'
        url.slashes.should.equal true
        url.host.should.equal 'localhost:9001'
        url.port.should.equal '9001'
        url.hostname.should.equal 'localhost'
        url.href.should.equal 'http://localhost:9001/demo.html?a=1&b=2#c=1'
        url.hash.should.equal '#c=1'
        url.search.should.equal '?a=1&b=2'
        url.query.should.equal 'a=1&b=2'
        url.pathname.should.equal '/demo.html'
        url.path.should.equal '/demo.html?a=1&b=2'
        done()

  describe '#navigateTo', ->

    it 'could redirect to target by absolute url', (done) ->
      browser.navigateTo '/demo.html'
      browser.element('body').text (text) ->
        text.should.contain 'this is a demo page !'
        done()

    it 'could redirect to target by relative url', (done) ->
      browser.navigateTo 'demo.html'
      browser.element('body').text (text) ->
        text.should.contain 'this is a demo page !'
        done()

  describe '#refresh', ->

    it 'could refresh browser', (done) ->
      selector = 'input[name="textbox"]';
      browser.input(selector).enter 'hello world'
      browser.refresh()
      browser.input(selector).value (val) ->
        val.should.be.empty
        done()

  describe '#back', ->

    it 'could go back to the page in history', (done) ->
      selector = '#link'
      browser.element(selector).click()
      browser.back()
      browser.element('body').text (text) ->
        text.should.contain 'Go to demo'
        done()

  describe '#forward', ->

    it 'could go forward to the page in history', (done) ->
      selector = '#link'
      browser.element(selector).click()
      browser.back()
      browser.forward()
      browser.element('body').text (text) ->
        text.should.contain 'this is a demo page !'
        done()

  describe '#title', ->

    it 'could get title of current page', (done) ->
      browser.title (title) ->
        title.should.equal 'THIS IS INDEX'
        done()

  describe '#exec', ->

    it 'should run an executable javascript', (done) ->
      browser.exec 'alert("hello world!");', ->
        browser.dialog().text (text) ->
          text.should.equal 'hello world!'
          browser.dialog().dismiss -> done()

    it 'should run an executable javascript with args', (done) ->
      browser.exec 'alert(arguments[0][0]);', ['hello!'], ->
        browser.dialog().text (text) ->
          text.should.equal 'hello!'
          browser.dialog().dismiss -> done()

    it 'should run an executable javascript with webelement selector', (done) ->
      browser.exec 'alert(arguments[0][0].name)', browser.elements('input[type="checkbox"]')
      browser.dialog().text (text) ->
        text.should.equal 'checkbox'
        browser.dialog().dismiss -> done()

  describe '#execAsync', ->

    it 'should run an executable async javascript', (done) ->
      browser.manage().timeouts().setScriptTimeout(5000);
      browser.execAsync 'var callback = arguments[arguments.length - 1];setTimeout(function(){ callback(10); }, 500);', (num) ->
        num.should.equal 10
        done()

    it 'should run an executable async javascript with args', (done) ->
      browser.manage().timeouts().setScriptTimeout(5000);
      browser.execAsync 'var callback = arguments[arguments.length - 1];var str = arguments[0][0];setTimeout(function(){ callback(str); }, 500);', ['hello world'], (str) ->
        str.should.equal 'hello world'
        done()
    
    it 'should run an executable async javascript with webelement selector', (done) ->
      browser.manage().timeouts().setScriptTimeout(5000);
      browser.execAsync 'var callback = arguments[arguments.length - 1];var elem = arguments[0][0];setTimeout(function(){ callback(elem); }, 500);', browser.elements('input[type="checkbox"]'), (elem) ->
        elem.attr 'name', (name) -> 
          name.should.equal 'checkbox'
          done()   
