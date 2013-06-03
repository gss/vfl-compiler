if typeof process is 'object' and process.title is 'node'
  chai = require 'chai' unless chai
  parser = require '../lib/vfl-compiler'
else
  parser = require 'vfl-compiler'

describe 'VFL compiler', ->
  it 'should provide a parse method', ->
    chai.expect(parser.parse).to.be.a 'function'
    
  describe 'with a simple VFL rule', ->
    source = """
    @-gss-horizontal |-[#box1]-[#button1]-| in(#dialog);
    """
    result = null
    it 'should be able to produce a result', ->
      result = parser.parse source
      chai.expect(result).to.be.an 'object'
