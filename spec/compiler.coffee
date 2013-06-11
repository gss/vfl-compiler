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
            @horizontal [#b1][#b2];
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
            @vertical [#b1]-[#b2]-[#b3];
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
      result = parser.parse source 
      chai.expect(result).to.eql expect
      
  describe '@horizontal [#b1]-100-[#b2]-8-[#b3]; // explicit gaps ', ->
    source = """
            @horizontal [#b1]-100-[#b2]-8-[#b3];
    """
    result = null
    expect = 
      [
        [
          'ccss'
          "#b1[right] + 100 == #b2[left]"
          "#b2[right] + 8 == #b3[left]"
        ]
      ]            
    it '/ the result should match the expectation', ->
      result = parser.parse source 
      chai.expect(result).to.eql expect
  
  describe '@horizontal [#b1]~[#b2]; // simple cushion ', ->
    source = """
            @horizontal [#b1]~[#b2];
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
      result = parser.parse source 
      chai.expect(result).to.eql expect
  
  describe '@horizontal [#b1]~-~[#b2]~100~[#b3]; // cushions w/ gaps ', ->
    source = """
            @horizontal [#b1]~-~[#b2]~100~[#b3];
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
      result = parser.parse source 
      chai.expect(result).to.eql expect
  
  describe '@vertical |[#sub]| in(#parent); // flush with super view', ->
    source = """
            @vertical |[#sub]| in(#parent);
    """
    result = null
    expect = 
      [
        [
          'ccss'
          '#parent[top] == #sub[top]'
          '#sub[bottom] == #parent[bottom]'          
        ]
      ]            
      
    it '/ the result should match the expectation', ->
      result = parser.parse source 
      chai.expect(result).to.eql expect
  
  describe '@horizontal |-[#sub1]-[#sub2]-| in(#parent); // super view with standard gaps', ->
    source = """
            @horizontal |-[#sub1]-[#sub2]-| in(#parent);
    """
    result = null
    expect = 
      [
        [
          'ccss'
          '#parent[left] + [hgap] == #sub1[left]'
          '#sub1[right] + [hgap] == #sub2[left]'          
          '#sub2[right] + [hgap] == #parent[right]'          
        ]
      ]            
      
    it '/ the result should match the expectation', ->
      result = parser.parse source 
      chai.expect(result).to.eql expect
  
  describe '@horizontal |-1-[#sub]-2-| in(#parent); // super view with explicit gaps', ->
    source = """
            @horizontal |-1-[#sub]-2-| in(#parent);
    """
    result = null
    expect = 
      [
        [
          'ccss'
          '#parent[left] + 1 == #sub[left]'
          '#sub[right] + 2 == #parent[right]'          
        ]
      ]            
      
    it '/ the result should match the expectation', ->
      result = parser.parse source 
      chai.expect(result).to.eql expect
  
  describe '@horizontal |~[#sub]~2~| in(#parent); // super view with cushions', ->
    source = """
            @horizontal |~[#sub]~2~| in(#parent);
    """
    result = null
    expect = 
      [
        [
          'ccss'
          '#parent[left] <= #sub[left]'
          '#sub[right] + 2 <= #parent[right]'          
        ]
      ]            
      
    it '/ the result should match the expectation', ->
      result = parser.parse source 
      chai.expect(result).to.eql expect
      
    

