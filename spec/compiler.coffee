if typeof process is 'object' and process.title is 'node'
  chai = require 'chai' unless chai
  compiler = require '../lib/compiler'
else
  compiler = require 'vfl-compiler'

describe 'VFL-to-AST Compiler', ->

  it 'should provide a parse method', ->
    chai.expect(compiler.parse).to.be.a 'function'

  describe 'parsing a basic VFL statement', ->
    statement = "@horizontal [#b1][#b2];"
    expected =
      selectors: ["#b1", "#b2"]
      vars: [
        ["get", "#b1[right]", "right", ["$id", "b1"]]
        ["get", "#b2[left]", "left", ["$id", "b2"]]
      ]
      constraints: [
        ["eq", ["get", "#b1[right]"], ["get", "#b2[left]"]]
      ]
    result = null
    it 'should be able to parse', ->
      result = compiler.parse statement
    it 'should provide the desired AST', ->
      chai.expect(result).to.eql expected
