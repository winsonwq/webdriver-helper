webdriver = require 'selenium-webdriver'
_ = require 'underscore'
require('chai').should()
require('../../lib/webdriver-helper')

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

  describe 'input[name="textbox"]', ->

    selector = 'input[name="textbox"]'

    it 'should enter value in textbox', (done) ->
      input = driver.input selector
      input.enter 'hello input'
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




