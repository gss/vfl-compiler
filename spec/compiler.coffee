if typeof process is 'object' and process.title is 'node'
  chai = require 'chai' unless chai
  compiler = require '../lib/compiler'
else
  compiler = require 'vfl-compiler'

compile = (vfl, ast) ->
  describe "with rule #{vfl}", ->
    result = null
    it 'should be able to parse', ->
      result = compiler.parse vfl
    it 'should produce the expected AST', ->
      chai.expect(result).to.eql ast

describe 'VFL-to-AST Compiler', ->

  it 'should provide a parse method', ->
    chai.expect(compiler.parse).to.be.a 'function'

  compile "@horizontal [#b1][#b2];",
    selectors: ["#b1", "#b2"]
    vars: [
      ["get", "#b1[right]", "right", ["$id", "b1"]]
      ["get", "#b2[left]", "left", ["$id", "b2"]]
    ]
    constraints: [
      ["eq", ["get", "#b1[right]"], ["get", "#b2[left]"]]
    ]

  compile "@vertical [#b1]-[#b2]-[#b3]-[#b4]-[#b5];",
    selectors: [
      "#b1"
      "#b2"
      "#b3"
      "#b4"
      "#b5"
    ]
    vars: [
      ["get", "#b1[bottom]", "bottom", ["$id", "b1"]]
      ["get", "[vgap]", "vgap"]
      ["get", "#b2[top]", "top", ["$id", "b2"]]
      ["get", "#b2[bottom]", "bottom", ["$id", "b2"]]
      ["get", "#b3[top]", "top", ["$id", "b3"]]
      ["get", "#b3[bottom]", "bottom", ["$id", "b3"]]
      ["get", "#b4[top]", "top", ["$id", "b4"]]
      ["get", "#b4[bottom]", "bottom", ["$id", "b4"]]
      ["get", "#b5[top]", "top", ["$id", "b5"]]
    ]
    constraints: [
      ['eq',
        ['plus', ['get', '#b1[bottom]'], ['get', '[vgap]']]
        ['get', '#b2[top]']
      ]
      ['eq',
        ['plus', ['get', '#b2[bottom]'], ['get', '[vgap]']]
        ['get', '#b3[top]']
      ]
      ['eq',
        ['plus', ['get', '#b3[bottom]'], ['get', '[vgap]']]
        ['get', '#b4[top]']
      ]
      ['eq',
        ['plus', ['get', '#b4[bottom]'], ['get', '[vgap]']]
        ['get', '#b5[top]']
      ]
    ]

  compile "@horizontal [#b1]-100-[#b2];",
    selectors: ["#b1", "#b2"]
    vars: [
      ["get", "#b1[right]", "right", ["$id", "b1"]]
      ["get", "#b2[left]", "left", ["$id", "b2"]]
    ]
    constraints: [
      ["eq",
        ["plus", ["get", "#b1[right]"], ["number", 100]]
        ["get", "#b2[left]"]
      ]
    ]
