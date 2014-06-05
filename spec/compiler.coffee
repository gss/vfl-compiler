if window?
  parser = require 'vfl-compiler'
else
  chai = require 'chai' unless chai
  parser = require '../lib/compiler'

{expect} = chai


parse = (source, expectation, pending) ->
  itFn = if pending then xit else it

  describe source, ->
    result = null

    itFn 'should do something', ->
      result = parser.parse source
      expect(result).to.be.an 'array'
    itFn 'should match expected', ->
      expect(result).to.eql expectation


# Helper function for expecting errors to be thrown when parsing.
#
# @param source [String] VFL statements.
# @param message [String] This should be provided when a rule exists to catch
# invalid syntax, and omitted when an error is expected to be thrown by the PEG
# parser.
# @param [Boolean] Whether the spec should be treated as pending.
#
expectError = (source, message, pending) ->
  itFn = if pending then xit else it

  describe source, ->
    predicate = 'should throw an error'
    predicate = "#{predicate} with message: #{message}" if message?

    itFn predicate, ->
      exercise = -> parser.parse source
      expect(exercise).to.throw Error, message


describe 'VFL-to-CCSS Compiler', ->
  
  it 'should provide a parse method', ->
    expect(parser.parse).to.be.a 'function'

  # Basics
  # --------------------------------------------------
  
  describe '/* Basics */', ->

    parse """
            @horizontal [#b1][#b2]; // simple connection
          """
        ,
          [
            "#b1[right] == #b2[left]"
          ]
    
    parse """
            @h [#b1][#b2]; // shorthand
          """
        ,
          [
            "#b1[right] == #b2[left]"
          ]
    
    parse """
            @v [#b1][#b2]; // shorthand
          """
        ,
          [
            "#b1[bottom] == #b2[top]"
          ]
    
    parse """
            @vertical [#b1]-[#b2]-[#b3]-[#b4]-[#b5]; // implicit standard gaps
          """
        ,
          [
            "#b1[bottom] + [vgap] == #b2[top]"
            "#b2[bottom] + [vgap] == #b3[top]"
            "#b3[bottom] + [vgap] == #b4[top]"
            "#b4[bottom] + [vgap] == #b5[top]"
          ]
    
    parse """
            @vertical [#b1]-[#b2]-[#b3]-[#b4]-[#b5] gap(20); // explicit standard gaps
          """
        ,
          [
            "#b1[bottom] + 20 == #b2[top]"
            "#b2[bottom] + 20 == #b3[top]"
            "#b3[bottom] + 20 == #b4[top]"
            "#b4[bottom] + 20 == #b5[top]"
          ]
    
    parse """
            @horizontal [#b1]-100-[#b2]-8-[#b3]; // explicit gaps
          """
        ,
          [
            "#b1[right] + 100 == #b2[left]"
            "#b2[right] + 8 == #b3[left]"              
          ]
    
    parse """
            @horizontal [#b1][#b2]-[#b3]-100-[#b4] gap(20); // mix gaps
          """
        ,
          [
            "#b1[right] == #b2[left]"
            "#b2[right] + 20 == #b3[left]"
            "#b3[right] + 100 == #b4[left]"
          ]
    
    parse """
            @horizontal [#b1]-100-[#b2]-[#b3]-[#b4] gap([col-width]); // variable standard gap
          """
        ,
          [
            "#b1[right] + 100 == #b2[left]"
            "#b2[right] + [col-width] == #b3[left]"
            "#b3[right] + [col-width] == #b4[left]"
          ]
    
    parse """
            @horizontal [#b1]-100-[#b2]-[#b3]-[#b4] gap(#box1[width]); // view variable standard gap
          """
        ,
          [
            "#b1[right] + 100 == #b2[left]"
            "#b2[right] + #box1[width] == #b3[left]"
            "#b3[right] + #box1[width] == #b4[left]"
          ]
    
    parse """
            @vertical ["Zone"]-["1"]-["a"]-["q-1"]-["_fallout"]; // virtuals
          """
        ,
          [
            '"Zone"[bottom] + [vgap] == "1"[top]'
            '"1"[bottom] + [vgap] == "a"[top]'
            '"a"[bottom] + [vgap] == "q-1"[top]'
            '"q-1"[bottom] + [vgap] == "_fallout"[top]'
          ]
  

    
    
  
     
  # Element Containment
  # --------------------------------------------------
  
  describe '/* Element Containment */', ->
    
    parse """
            @vertical |[#sub]| in(#parent); // flush with super view
          """
        ,
          [
            '#parent[top] == #sub[top]'
            '#sub[bottom] == #parent[bottom]'          
          ]
    
    parse """
            @vertical |["sub"]| in("parent"); // virtuals
          """
        ,
          [
            '"parent"[top] == "sub"[top]'
            '"sub"[bottom] == "parent"[bottom]'          
          ]
          
    
    parse """
            @v |[#sub]|; // super view defaults to ::this
          """
        ,
          [
            '::this[top] == #sub[top]'
            '#sub[bottom] == ::this[bottom]'          
          ]
    
    parse """
            @horizontal |-[#sub1]-[#sub2]-| in(#parent); // super view with standard gaps
          """
        ,
          [
            '#parent[left] + [hgap] == #sub1[left]'
            '#sub1[right] + [hgap] == #sub2[left]'          
            '#sub2[right] + [hgap] == #parent[right]'
          ]
    
    parse """
            @h |-1-[#sub]-2-| in(#parent); // super view with explicit gaps
          """
        ,
          [
            '#parent[left] + 1 == #sub[left]'
            '#sub[right] + 2 == #parent[right]'
          ]
    
    parse """
            @horizontal |-|#sub|-| in(#parent) gap(100); // super view with explicit standard gaps
          """
        ,
          [
            '#parent[left] + 100 == #sub[left]'
            '#sub[right] + 100 == #parent[right]'
          ]
    
    parse """
            @horizontal |-[#sub1]-[#sub2]-| in(#parent) outer-gap(10); // outer-gap
          """
        ,
          [
            '#parent[left] + 10 == #sub1[left]'
            '#sub1[right] + [hgap] == #sub2[left]'          
            '#sub2[right] + 10 == #parent[right]'
          ]
    
    parse """
            @horizontal |-[#sub1]-[#sub2]-| in(#parent) gap(8) outer-gap([baseline]); // outer-gap
          """
        ,
          [
            '#parent[left] + [baseline] == #sub1[left]'
            '#sub1[right] + 8 == #sub2[left]'          
            '#sub2[right] + [baseline] == #parent[right]'
          ]
  

    
    
  
     
  # Points
  # --------------------------------------------------
  
  describe '/* Points */', ->
    
    parse """
            @v <100>[#sub]<300>; // point containment
          """
        ,
          [
            '100 == #sub[top]'
            '#sub[bottom] == 300'          
          ]
    
    parse """
            @h < "col1"[center-x] + 20 >-[#box1]-< ::window[center-x] >; // point containment
          """
        ,
          [
            '"col1"[center-x] + 20 + [hgap] == #box1[left]'
            '#box1[right] + [hgap] == ::window[center-x]'          
          ]
          
    parse """
            @h < [line] >-[#box1]-[#box2]; // point containment
          """
        ,
          [
            '[line] + [hgap] == #box1[left]'
            '#box1[right] + [hgap] == #box2[left]'
          ]
    
    parse """
            @h [#btn1]-<::window[center-x]>-[#btn2] gap(8); // point in alignment
          """
        ,
          [
            '#btn1[right] + 8 == ::window[center-x]'
            '::window[center-x] + 8 == #btn2[left]'          
          ]
    
    parse """
            @h [#btn1]-<::window[center-x]>-[#btn2] gap(8) chain-top chain-width(==); // chains ignore points
          """
        ,
          [
            '#btn1[right] + 8 == ::window[center-x]'
            '::window[center-x] + 8 == #btn2[left]'
            '#btn1[top] == #btn2[top]'
            '#btn1[width] == #btn2[width]'
          ]
          
    parse """
            @h [#btn1]-<"col3"[left]> 
                       <"col4"[right]>-[#btn2] 
              gap(8); 
              // consecutive points are not equalized
          """
        ,
          [
            '#btn1[right] + 8 == "col3"[left]'
            '"col4"[right] + 8 == #btn2[left]'          
          ]
    
      
    

          
            
  
  # Cushions
  # --------------------------------------------------
  
  describe '/* Cushions */', ->
    
    parse """
            @horizontal [#b1]~[#b2]; // simple cushion
          """
        ,
          [
            "#b1[right] <= #b2[left]"
          ]
    
    parse """
            @horizontal [#b1]~-~[#b2]~100~[#b3]; // cushions w/ gaps
          """
        ,
          [
            "#b1[right] + [hgap] <= #b2[left]"
            "#b2[right] + 100 <= #b3[left]"              
          ]
    
    parse """
            @horizontal |~[#sub]~2~| in(#parent); // super view with cushions
          """
        ,
          [
            '#parent[left] <= #sub[left]'
            '#sub[right] + 2 <= #parent[right]'     
          ]
  
  
  # Predicates
  # --------------------------------------------------
  
  describe '/* Predicates */', ->
    
    parse """
            @vertical [#sub(==100)]; // single predicate
          """
        ,
          [
            '#sub[height] == 100'
          ]
    
    parse """
            @vertical [#box(<=100!required,>=30!strong100)]; // multiple predicates w/ strength & weight
          """
        ,
          [
            '#box[height] <= 100 !required'
            '#box[height] >= 30 !strong100'
          ]
    
    parse """
            @horizontal [#b1(<=100)][#b2(==#b1)]; // connected predicates
          """
        ,
          [
            '#b1[width] <= 100'
            '#b2[width] == #b1[width]'
            '#b1[right] == #b2[left]'
          ]
    
    parse """
            @horizontal ["b1"(<=100)]["b2"(=="b1")]; // virtuals
          """
        ,
          [
            '"b1"[width] <= 100'
            '"b2"[width] == "b1"[width]'
            '"b1"[right] == "b2"[left]'
          ]
          
    parse """
            @horizontal [#b1( <=100 , ==#b99 !99 )][#b2(>= #b1 *2  !weak10, <=3!required)]-100-[.b3(==200)] !medium200; // multiple, connected predicates w/ strength & weight
          """
        ,
          [
            '#b1[width] <= 100'
            '#b1[width] == #b99[width] !99'
            '#b2[width] >= #b1[width] * 2 !weak10'
            '#b2[width] <= 3 !required'
            '#b1[right] == #b2[left] !medium200'
            '.b3[width] == 200'
            '#b2[right] + 100 == .b3[left] !medium200'
          ]
    
    parse """
            @horizontal [#b1(==[colwidth])]; // predicate with constraint variable
          """
        ,
          [
            '#b1[width] == [colwidth]'
          ]
    
    parse """
            @horizontal [#b1(==#b2[height])]; // predicate with explicit view variable
          """
        ,
          [
            '#b1[width] == #b2[height]'
          ]
  
  
  # Chains
  # --------------------------------------------------
  
  describe '/* Chains */', ->
    
    parse """
            @horizontal [#b1][#b2] chain-height chain-width(250); // basic equality chains
          """
        ,
          [
            '#b1[right] == #b2[left]'
            '#b1[height] == #b2[height]'
            '#b1[width] == 250 == #b2[width]'          
          ]
    
    parse """
            @horizontal [#b1][#b2][#b3] chain-width(==[colwidth]!strong,<=500!required); // mutliple chain predicates
          """
        ,
          [
            '#b1[right] == #b2[left]'
            '#b2[right] == #b3[left]'
            '#b1[width] == [colwidth] == #b2[width] == [colwidth] == #b3[width] !strong'
            '#b1[width] <= 500 >= #b2[width] <= 500 >= #b3[width] !required'
          ]
          
    parse """
            @vertical [#b1][#b2][#b3][#b4] chain-width(==!weak10) chain-height(<=150>=!required) !medium; // explicit equality & inequality chains
          """
        ,
          [
            '#b1[bottom] == #b2[top] !medium'
            '#b2[bottom] == #b3[top] !medium'
            '#b3[bottom] == #b4[top] !medium'
            '#b1[width] == #b2[width] == #b3[width] == #b4[width] !weak10'
            '#b1[height] <= 150 >= #b2[height] <= 150 >= #b3[height] <= 150 >= #b4[height] !required'
          ]
    
    parse """
            @vertical [#b1(==100!strong)] chain-centerX chain-width( 50 !weak10); // single view w/ equality chains
          """
        ,
          [
            '#b1[height] == 100 !strong'
          ]
    
    parse """
            @vertical |-8-[#b1(==100!strong)][#b2]-8-| in(#panel) chain-centerX( #panel[centerX] !required) chain-width(>=50=<!weak10); // adv w/ super views & chains
          """
        ,
          [
            '#b1[height] == 100 !strong'
            '#panel[top] + 8 == #b1[top]'
            '#b1[bottom] == #b2[top]'
            '#b2[bottom] + 8 == #panel[bottom]'              
            '#b1[centerX] == #panel[centerX] == #b2[centerX] !required'
            '#b1[width] >= 50 <= #b2[width] !weak10'
          ]
    
    parse """
            @vertical |-[#b1]-[#b2]-| in("panel") gap("zone"[col-size]) outer-gap("outer-zone"[row-size]) chain-centerX( "panel"[centerX] !required); // adv w/ virtuals
          """
        ,
          [
            '"panel"[top] + "outer-zone"[row-size] == #b1[top]'
            '#b1[bottom] + "zone"[col-size] == #b2[top]'
            '#b2[bottom] + "outer-zone"[row-size] == "panel"[bottom]'              
            '#b1[centerX] == "panel"[centerX] == #b2[centerX] !required'
          ]
  
  # Plural selectors
  # --------------------------------------------------
  
  describe '/* Plural selectors */', ->
    
    parse """
            @vertical .box;
          """
        ,
          [
            '@chain .box bottom()top'
          ]
    
    parse """
            @horizontal .box chain-width chain-height();
          """
        ,
          [
            '@chain .box right()left width() height()'
          ]
    
    parse """
            @horizontal .box gap(20);
          """
        ,
          [
            '@chain .box right(+20)left'
          ]
    
    ### TODO
    parse """
            @horizontal .box gap(20) in("area");
          """
        ,
          [
            '@chain .box ("area"[left])right(+20)left("area"[right])'
          ]
    ###
    
    parse """
            @vertical .super-box gap([vgap]);
          """
        ,
          [
            '@chain .super-box bottom(+[vgap])top'
          ]
    
    parse """
            @vertical .super-box gap([vgap]) chain-center-x(::window[center-x] !medium100) !strong;
          """
        ,
          [
            '@chain .super-box bottom(+[vgap])top center-x(::window[center-x]!medium100) !strong'
          ]
      
  
  # Names
  # --------------------------------------------------
  
  describe '/* Names */', ->
    
    parse """
            @horizontal [#b1]-100-[#b2]-[#b3]-[#b4] gap(#box1[width]) name(button-layout) !strong; // view variable standard gap
          """
        ,
          [
            "#b1[right] + 100 == #b2[left] name(button-layout) !strong"
            "#b2[right] + #box1[width] == #b3[left] name(button-layout) !strong"
            "#b3[right] + #box1[width] == #b4[left] name(button-layout) !strong"
          ]
    
    parse """
            @horizontal [#b1]-100-[#b2]-[#b3]-[#b4] gap(#box1[width]) !strong name(button-layout); // view variable standard gap
          """
        ,
          [
            "#b1[right] + 100 == #b2[left] name(button-layout) !strong"
            "#b2[right] + #box1[width] == #b3[left] name(button-layout) !strong"
            "#b3[right] + #box1[width] == #b4[left] name(button-layout) !strong"
          ]
    
    parse """
            @vertical [#b1][#b2][#b3][#b4] chain-width(==) chain-height(<=150>=!required) name(bob) !medium; // explicit equality & inequality chains
          """
        ,
          [
            '#b1[bottom] == #b2[top] name(bob) !medium'
            '#b2[bottom] == #b3[top] name(bob) !medium'
            '#b3[bottom] == #b4[top] name(bob) !medium'
            '#b1[width] == #b2[width] == #b3[width] == #b4[width] name(bob)'
            '#b1[height] <= 150 >= #b2[height] <= 150 >= #b3[height] <= 150 >= #b4[height] name(bob) !required'
          ]
    
    parse """
            @vertical .super-box gap([vgap]) chain-center-x(::window[center-x] !medium100) name(frank) !strong;
          """
        ,
          [
            '@chain .super-box bottom(+[vgap])top center-x(::window[center-x]!medium100) name(frank) !strong'
          ]
