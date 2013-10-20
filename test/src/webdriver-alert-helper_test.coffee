webdriver = require 'selenium-webdriver'
builder = require './webdriver-builder'

should = require('chai').should()
require('../../lib/webdriver-helper')

describe 'webdriver alert helper', ->

  browser = null
  host = 'http://localhost:9001'

  before -> browser = builder.build()
  beforeEach -> browser.get host
  after -> browser.quit()

  describe 'alert dialog', ->

    describe '#text', ->

      it 'could return text of alert window', (done) ->
        browser.input('#alert-btn').click()
        browser.dialog().text (text) ->
          browser.dialog().dismiss()
          text.should.equal 'button clicked!!!!'
          done()

    describe '#dismiss', ->

      it 'could cancel the alert dialog', (done) ->
        browser.input('#alert-btn').click()
        browser.dialog().dismiss -> done()

  describe 'confirm dialog', ->

    describe '#accept', ->

      it 'could accept the confirm dialog', (done) ->
        browser.input('#confirm-btn').click()
        browser.dialog().accept()
        browser.element('body').text (text) ->
          text.should.contain 'I am ok!'
          done()

    describe '#dismiss', ->

      it 'could cancel the confirm dialog', (done) ->
        browser.input('#confirm-btn').click()
        browser.dialog().dismiss()
        browser.element('body').text (text) ->
          text.should.not.contain 'I am ok!'
          done()

  describe 'prompt dialog', ->

    describe '#enter', ->

      it 'could enter text', (done) ->
        browser.input('#prompt-btn').click()
        browser.dialog().enter 'your name!'
        browser.dialog().accept()
        browser.element('body').text (text) ->
          text.should.contain 'your name!'
          done()



      
      
        