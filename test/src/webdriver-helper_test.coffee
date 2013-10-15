chai = require 'chai'
chai.should()

describe 'hello world', ->

  it 'should be ok', (done) ->
    (1).should.equal 1
    done()
