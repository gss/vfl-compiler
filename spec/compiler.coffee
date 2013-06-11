if typeof process is 'object' and process.title is 'node'
  chai = require 'chai' unless chai
  parser = require '../lib/vfl-compiler'
else
  parser = require 'vfl-compiler'

describe 'VFL compiler', ->
  it 'should provide a parse method', ->
    chai.expect(parser.parse).to.be.a 'function'
    
  describe '@horizontal [#b1][#b2]; // simple connection ', ->
    source = """
    @-gss-horizontal [#b1][#b2];
    """
    result = null
    expect = 
      [
        [
          'ccss'
          "#b1[right] == #b2[left]"
        ]
      ]
              
    it 'should be able to produce a result', ->
      result = parser.parse source 
      chai.expect(result).to.be.an 'object'
      
    it '/ the result should match the expectation', ->
      chai.expect(result).to.eql expect
  
  describe '@vertical [#b1]-[#b2]-[#b3]-[#b4]-[#b5]; // connection chain with implicit hgaps ', ->
    source = """
    @-gss-vertical [#b1]-[#b2]-[#b3];
    """
    result = null
    expect = 
      [
        [
          'ccss'
          "#b1[bottom] + [hgap] == #b2[top]"
          "#b2[bottom] + [hgap] == #b3[top]"    
          "#b3[bottom] + [hgap] == #b4[top]"    
          "#b4[bottom] + [hgap] == #b5[top]"    
        ]
      ]              
    it '/ the result should match the expectation', ->
      chai.expect(result).to.eql expect
      
  describe '@horizontal [#b1]-100-[#b2]-[#b3] gap(1); // explicit gaps ', ->
    source = """
    @-gss-h [#b1]-100-[#b2]-[#b3] gap(1);
    """
    result = null
    expect = 
      [
        [
          'ccss'
          "#b1[right] + 100 == #b2[left]"
          "#b2[right] + 1 == #b3[left]"
        ]
      ]            
    it '/ the result should match the expectation', ->
      chai.expect(result).to.eql expect
  
  describe '@horizontal [#b1]~[#b2]; // simple cushion ', ->
    source = """
    @-gss-h [#b1]~[#b2];
    """
    result = null
    expect = 
      [
        [
          'ccss'
          "#b1[right] <= #b2[left]"
        ]
      ]            
    it '/ the result should match the expectation', ->
      chai.expect(result).to.eql expect
  
  describe '@horizontal [#b1]~-~[#b2]~100~[#b3]; // cushions w/ gaps ', ->
    source = """
    @-gss-h [#b1]~-~[#b2]~100~[#b3];
    """
    result = null
    expect = 
      [
        [
          'ccss'
          "#b1[right] + [hgap] <= #b2[left]"
          "#b2[right] + 100 <= #b3[left]"
        ]
      ]            
    it '/ the result should match the expectation', ->
      chai.expect(result).to.eql expect

