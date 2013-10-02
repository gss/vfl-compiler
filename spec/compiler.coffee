if typeof process is 'object' and process.title is 'node'
  chai = require 'chai' unless chai
  compiler = require '../lib/compiler'
else
  compiler = require 'vfl-compiler'

# full compile check
compile = (vfl, ast) ->
  describe "with rule #{vfl}", ->
    result = null
    it 'can parse', ->
      result = compiler.parse vfl
    it 'produces expected', ->
      chai.expect(result).to.eql ast

compile_contains = (vfl, commands) ->
  describe "with rule #{vfl}", ->
    result = null
    it 'can parse', ->
      result = compiler.parse vfl
    it 'contains the expected', ->
      #chai.expect(result.commands).to.include.members commands
      r = JSON.stringify result.commands
      for command in commands
        chai.expect(r).to.contain JSON.stringify command

describe 'VFL-to-AST Compiler', ->

  it 'should provide a parse method', ->
    chai.expect(compiler.parse).to.be.a 'function'
  
  # full compiled results test
  compile "@horizontal [#b1][#b2];",
    selectors: ["#b1", "#b2"]
    commands: [
      ["var", "#b1[x]", "x", ["$id", "b1"]]
      ["var", "#b1[width]", "width", ["$id", "b1"]]
      ['varexp', '#b1[right]', ['plus',['get','#b1[x]'],['get','#b1[width]']], ['$id','b1']]
      ["var", "#b2[left]", "left", ["$id", "b2"]]
      ["eq", ["get", "#b1[right]"], ["get", "#b2[left]"]]
    ]

  compile_contains "@vertical [#b1]-[#b2]-[#b3]-[#b4]-[#b5];", [
      ["var", "#b1[height]", "height", ["$id", "b1"]]
      ["var", "[vgap]", "vgap"]
      ["var", "#b2[top]", "top", ["$id", "b2"]]
      ["var", "#b2[height]", "height", ["$id", "b2"]]
      ["var", "#b3[top]", "top", ["$id", "b3"]]
      ["var", "#b3[height]", "height", ["$id", "b3"]]
      ["var", "#b4[top]", "top", ["$id", "b4"]]
      ["var", "#b4[height]", "height", ["$id", "b4"]]
      ["var", "#b5[top]", "top", ["$id", "b5"]]
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

  compile_contains "@horizontal [#b1]-100-[#b2];", [
      ["var", "#b1[width]", "width", ["$id", "b1"]]
      ["var", "#b2[left]", "left", ["$id", "b2"]]
      ["eq",
        ["plus", ["get", "#b1[right]"], ["number", 100]]
        ["get", "#b2[left]"]
      ]
    ]
  
