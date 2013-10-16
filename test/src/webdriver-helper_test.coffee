webdriver = require 'selenium-webdriver'
_ = require 'underscore'
require('chai').should()
require('../../lib/webdriver-helper')

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

  describe 'attr', ->

    it 'could get attribute value of element', (done) ->
      input = driver.input 'input[name="textbox"]'
      input.attr 'name', (name) -> 
        name.should.equal 'textbox'
        done()

  describe 'input[name="textbox"]', ->

    selector = 'input[name="textbox"]'
    input = null

    beforeEach ->
      input = driver.input selector

    it 'could enter value in textbox', (done) ->
      input.enter 'hello input'
      input.value (value) ->
        value.should.equal 'hello input'
        this.should.equal input
        done()

    it 'could enter value in textbox in aync syntax', (done) ->
      input.enter 'hello input', ->
        input.value (value) ->
          value.should.equal 'hello input'
          this.should.equal input
          done()

  describe 'input[name="checkbox"]', ->

    selector = 'input[name="checkbox"]'
    checkbox = null

    beforeEach ->
      checkbox = driver.input selector

    it 'could be checked', (done) ->
      checkbox.check()
      checkbox.isChecked (checked) ->
        checked.should.be.true
        done()

    it 'could be unchecked', (done) ->
      checkbox.check()
      checkbox.uncheck()
      checkbox.isChecked (checked) ->
        checked.should.be.false
        done()

  describe 'input[name="radio"]', ->

    selector = 'input[name="radio"]'
    [radioA, radioB] = [null, null]

    beforeEach ->
      radioA = driver.element "#{selector}[value=\"1\"]"
      radioB = driver.element "#{selector}[value=\"2\"]"

    it 'could be selected', (done) ->
      radioA.select()
      radioA.isSelected (selected) ->
        selected.should.be.true
        done()

    it 'could be unselected by value seleting another radio with same name', (done) ->
      radioA.select()
      radioB.select()
      radioA.isSelected (selected) ->
        selected.should.be.false
        done()      

  describe 'input[name="button"]', ->

    it 'could be clicked', (done) ->
      driver.input('input[name="button"]').click ->
        driver.element('body').text (text) ->
          text.should.contain 'button clicked!!'
          done()

  describe 'select[name="dropdownlist"]', ->

    selector = '[name="dropdownlist"]'
    dropdownlist = null

    beforeEach ->
      dropdownlist = driver.dropdownlist selector

    it 'could be set to the correct option as per assigned value', (done) ->
      dropdownlist.option '2'
      dropdownlist.value (value) ->
        value.should.equal '2'
        done()

  describe 'select[name="multi-select-dropdownlist"]', ->

    selector = '[name="multi-select-dropdownlist"]'
    dropdownlist = null

    beforeEach ->
      dropdownlist = driver.dropdownlist selector

    it 'could be set to the correct option as per assigned value', (done) ->
      dropdownlist.option '2', '3'
      dropdownlist.value (value) ->
        value.should.equal '2'

        dropdownlist.values (values) ->
          values.should.eql ['2', '3']
          done()

  describe 'elements', ->

    it 'should be initialized before doing other actions', (done) ->
      elements = driver.elements('input')
      elements.initialized.should.be.false

      elements.init (elems) ->
        this.initialized.should.be.true
        done()

    it 'should return count of selected elements', (done) ->
      driver.elements('input').count (count) ->
        count.should.equal 5
        done()

    it 'should return count of selected elements immediately after being initialized', (done) ->
      driver.elements('input').init (elems) ->
        this.count().should.equal 5
        done()

    describe 'get element inside', ->

      it 'could get element inside when not initialized', (done) ->
        driver.elements('input').get 0, (elem) -> 
          elem.attr 'name', (name) ->
            name.should.equal 'textbox'
            done()

      it 'could get element inside when initialized', (done) ->
        driver.elements('input').init (elems) ->
          elems[0].attr 'name', (name) ->
            name.should.equal 'textbox'
            done()

