if typeof process is 'object' and process.title is 'node'
  chai = require 'chai' unless chai
  parser = require '../lib/vfl-compiler'
else
  parser = require 'vfl-compiler/lib/vfl-compiler.js'

parse = (source, expect) ->
  result = null
  describe source, ->
    it 'should do something', ->
      result = parser.parse source
      chai.expect(result).to.be.an 'array'
    it 'should match expected', ->
      chai.expect(result).to.eql expect

describe 'VFL-to-CCSS Compiler', ->
  
  it 'should provide a parse method', ->
    chai.expect(parser.parse).to.be.a 'function'

  # Basics
  # --------------------------------------------------
  
  describe '/* Basics */', ->

    parse """
            @horizontal [#b1][#b2]; // simple connection
          """
        ,
          [
            [
              'ccss'
              "#b1[right] == #b2[left]"
            ]
          ]
    
    parse """
            @vertical [#b1]-[#b2]-[#b3]-[#b4]-[#b5]; // connection chain with implicit hgaps
          """
        ,
          [
            [
              'ccss'
              "#b1[bottom] + [vgap] == #b2[top]"
              "#b2[bottom] + [vgap] == #b3[top]"    
              "#b3[bottom] + [vgap] == #b4[top]"    
              "#b4[bottom] + [vgap] == #b5[top]"    
            ]
          ]
    
    parse """
            @horizontal [#b1]-100-[#b2]-8-[#b3];
          """
        ,
          [
            [
              'ccss'
              "#b1[right] + 100 == #b2[left]"
              "#b2[right] + 8 == #b3[left]"              
            ]
          ]
             
  # Containment
  # --------------------------------------------------
  
  describe '/* Containment */', ->
    
    parse """
            @vertical |[#sub]| in(#parent); // flush with super view
          """
        ,
          [
            [
              'ccss'
              '#parent[top] == #sub[top]'
              '#sub[bottom] == #parent[bottom]'          
            ]
          ]
    
    parse """
            @vertical |[#sub]|; // super view defaults to ::this
          """
        ,
          [
            [
              'ccss'
              '::this[top] == #sub[top]'
              '#sub[bottom] == ::this[bottom]'          
            ]
          ]
    
    parse """
            @horizontal |-[#sub1]-[#sub2]-| in(#parent); // super view with standard gaps
          """
        ,
          [
            [
              'ccss'
              '#parent[left] + [hgap] == #sub1[left]'
              '#sub1[right] + [hgap] == #sub2[left]'          
              '#sub2[right] + [hgap] == #parent[right]'
            ]
          ]
    
    parse """
            @horizontal |-1-[#sub]-2-| in(#parent); // super view with explicit gaps
          """
        ,
          [
            [
              'ccss'
              '#parent[left] + 1 == #sub[left]'
              '#sub[right] + 2 == #parent[right]'
            ]
          ]
  
  # Cushions
  # --------------------------------------------------
  
  describe '/* Cushions */', ->
    
    parse """
            @horizontal [#b1]~[#b2]; // simple cushion
          """
        ,
          [
            [
              'ccss'
              "#b1[right] <= #b2[left]"
            ]
          ]
    
    parse """
            @horizontal [#b1]~-~[#b2]~100~[#b3]; // cushions w/ gaps
          """
        ,
          [
            [
              'ccss'
              "#b1[right] + [hgap] <= #b2[left]"
              "#b2[right] + 100 <= #b3[left]"              
            ]
          ]
    
    parse """
            @horizontal |~[#sub]~2~| in(#parent); // super view with cushions
          """
        ,
          [
            [
              'ccss'
              '#parent[left] <= #sub[left]'
              '#sub[right] + 2 <= #parent[right]'     
            ]
          ]
  
  
  # Predicates
  # --------------------------------------------------
  
  describe '/* Predicates */', ->
    
    parse """
            @vertical [#sub(==100)]; // single predicate
          """
        ,
          [
            [
              'ccss'
              '#sub[height] == 100'                  
            ]
          ]
    
    parse """
            @vertical [#box(<=100!required,>=30!strong100)]; // multiple predicates w/ strength & weight
          """
        ,
          [
            [
              'ccss'
              '#box[height] <= 100 !required'
              '#box[height] >= 30 !strong100'                  
            ]
          ]
    
    parse """
            @horizontal [#b1(<=100)][#b2(==#b1)]; // connected predicates
          """
        ,
          [
            [
              'ccss'
              '#b1[width] <= 100'
              '#b2[width] == #b1[width]'
              '#b1[right] == #b2[left]'
            ]
          ]
          
    parse """
            @horizontal [#b1( <=100 , ==#b99 !99 )][#b2(>= #b1 *2  !weak10, <=3!required)]-100-[.b3(==200)] !medium200; // multiple, connected predicates w/ strength & weight
          """
        ,
          [
            [
              'ccss'
              '#b1[width] <= 100'
              '#b1[width] == #b99[width] !99'
              '#b2[width] >= #b1[width] * 2 !weak10'
              '#b2[width] <= 3 !required'
              '#b1[right] == #b2[left] !medium200'
              '.b3[width] == 200'
              '#b2[right] + 100 == .b3[left] !medium200'
            ]
          ]
    
    parse """
            @horizontal [#b1(==[colwidth])]; // predicate with constraint variable
          """
        ,
          [
            [
              'ccss'
              '#b1[width] == [colwidth]'
            ]
          ]
    
    parse """
            @horizontal [#b1(==#b2[height])]; // predicate with explicit view variable
          """
        ,
          [
            [
              'ccss'
              '#b1[width] == #b2[height]'
            ]
          ]

    
    

