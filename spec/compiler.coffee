if window?
  parser = require 'vfl-compiler'
else
  chai = require 'chai' unless chai
  parser = require '../lib/compiler'

{expect} = chai


parse = (sources, expectation, pending) ->
  itFn = if pending then xit else it


  if !(sources instanceof Array)
    sources = [sources]
  for source in sources

    describe source, ->
      result = null

      itFn 'should do something', ->
        result = parser.parse source
        expect(result.statements).to.be.an 'array'
        expect(result.selectors).to.be.an 'array'
      itFn 'should match expected', ->
        if expectation instanceof Array
          expect(result.statements).to.eql expectation
        else
          expect(result).to.eql expectation


# Helper function for expecting errors to be thrown when parsing.
#
# @param source [String] VFL statements.
# @param message [String] This should be provided when a rule exists to catch
# invalid syntax, and omitted when an error is expected to be thrown by the PEG
# parser.
# @param pending [Boolean] Whether the spec should be treated as pending.
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
            @horizontal (#b1)(#b2); // simple connection
          """
        ,
          [
            "#b1[right] == #b2[left]"
          ]

    parse """
            @h (#b1)(#b2); // shorthand
          """
        ,
          [
            "#b1[right] == #b2[left]"
          ]

    parse """
            @vertical (#b1)(#b2); // shorthand
          """
        ,
          [
            "#b1[bottom] == #b2[top]"
          ]

    parse """
            @v (#b1)-(#b2)  -  (#b3)- (#b4) -(#b5); // implicit standard gaps
          """
        ,
          [
            "#b1[bottom] + [vgap] == #b2[top]"
            "#b2[bottom] + [vgap] == #b3[top]"
            "#b3[bottom] + [vgap] == #b4[top]"
            "#b4[bottom] + [vgap] == #b5[top]"
          ]

    parse [
            """
              @v (#b1)-(#b2)-(#b3)-(#b4)-(#b5) gap(20); // explicit standard gaps
            """,
            """
              @v (#b1)
                  -
                 (#b2)
                  -20-
                 (#b3)
                  -20-
                 (#b4)
                  -
                 (#b5)

                 gap(20);
            """
          ]
        ,
          [
            "#b1[bottom] + 20 == #b2[top]"
            "#b2[bottom] + 20 == #b3[top]"
            "#b3[bottom] + 20 == #b4[top]"
            "#b4[bottom] + 20 == #b5[top]"
          ]

    parse [
            "@h (#b1)-100-(#b2)-8-(#b3); // explicit gaps",
            "@h (#b1) - 100 - (#b2) - 8 - (#b3); // explicit gaps"
          ],

          [
            "#b1[right] + 100 == #b2[left]"
            "#b2[right] + 8 == #b3[left]"
          ]

    parse """
            @h (#b1)-[my-gap]-(#b2)-[my-other-gap]-(#b3); // explicit var gaps
          """
        ,
          [
            "#b1[right] + [my-gap] == #b2[left]"
            "#b2[right] + [my-other-gap] == #b3[left]"
          ]

    parse """
            @v (#b1)
                -#box1.class1[width]-
               (#b2)
                -"virtual"[-my-custom-prop]-
               (#b3); // explicit view var gaps
          """
        ,
          [
            "#b1[bottom] + #box1.class1[width] == #b2[top]"
            """#b2[bottom] + "virtual"[-my-custom-prop] == #b3[top]"""
          ]

    parse """
            @h (#b1)(#b2)-(#b3)-100-(#b4) gap(20); // mix gaps
          """
        ,
          [
            "#b1[right] == #b2[left]"
            "#b2[right] + 20 == #b3[left]"
            "#b3[right] + 100 == #b4[left]"
          ]

    parse """
            @h (#b1)-100-(#b2)-(#b3)-(#b4) gap([col-width]); // variable standard gap
          """
        ,
          [
            "#b1[right] + 100 == #b2[left]"
            "#b2[right] + [col-width] == #b3[left]"
            "#b3[right] + [col-width] == #b4[left]"
          ]

    parse """
            @h (#b1)-100-(#b2)-(#b3)-(#b4) gap(#box1[width]); // view variable standard gap
          """
        ,
          [
            "#b1[right] + 100 == #b2[left]"
            "#b2[right] + #box1[width] == #b3[left]"
            "#b3[right] + #box1[width] == #b4[left]"
          ]

    parse """
            @v ("Zone")-("1")-("a")-("q-1")-("_fallout"); // virtuals
          """
        ,
          [
            '"Zone"[bottom] + [vgap] == "1"[top]'
            '"1"[bottom] + [vgap] == "a"[top]'
            '"a"[bottom] + [vgap] == "q-1"[top]'
            '"q-1"[bottom] + [vgap] == "_fallout"[top]'
          ]

    expectError '@h (#b1(#b2);'


    # Variable scope
    # --------------------------------------------------

    # Global

    parse """
            @h (#b1)-$[md]-(#b2)
          """
        ,
          [
            "#b1[right] + $[md] == #b2[left]"
          ]

    parse """
            @h (#b1)-$md-(#b2)
          """
        ,
          [
            "#b1[right] + $md == #b2[left]"
          ]

    expectError '@h (#b1)-$$md-(#b2)'


    # Parent

    parse """
            @h (#b1)-^[md]-(#b2)
          """
        ,
          [
            "#b1[right] + ^[md] == #b2[left]"
          ]

    parse """
            @h (#b1)-^md-(#b2)
          """
        ,
          [
            "#b1[right] + ^md == #b2[left]"
          ]

    parse """
            @h (#b1)-^^md-(#b2)
          """
        ,
          [
            "#b1[right] + ^^md == #b2[left]"
          ]


    #  Local

    parse """
            @h (#b1)-&[md]-(#b2)
          """
        ,
          [
            "#b1[right] + &[md] == #b2[left]"
          ]

    parse """
            @h (#b1)-&md-(#b2)
          """
        ,
          [
            "#b1[right] + &md == #b2[left]"
          ]

    expectError '@h (#b1)-&&md-(#b2)'






  # Element Containment
  # --------------------------------------------------

  describe '/* Element Containment */', ->

    parse """
            @v |(#sub)| in(#parent); // flush with super view
          """
        ,
          [
            '#parent[top] == #sub[top]'
            '#sub[bottom] == #parent[bottom]'
          ]

    parse """
            @v |("sub")| in("parent"); // virtuals
          """
        ,
          [
            '"parent"[top] == "sub"[top]'
            '"sub"[bottom] == "parent"[bottom]'
          ]


    parse """
            @v |(#sub)|; // super view defaults to ::this
          """
        ,
          [
            '::this[top] == #sub[top]'
            '#sub[bottom] == ::this[bottom]'
          ]

    parse """
            @h |-(#sub1)-(#sub2)-| in(#parent); // super view with standard gaps
          """
        ,
          [
            '#parent[left] + [hgap] == #sub1[left]'
            '#sub1[right] + [hgap] == #sub2[left]'
            '#sub2[right] + [hgap] == #parent[right]'
          ]

    parse """
            @h |-1-(#sub)-2-| in(#parent); // super view with explicit gaps
          """
        ,
          [
            '#parent[left] + 1 == #sub[left]'
            '#sub[right] + 2 == #parent[right]'
          ]

    parse """
            @v |
                -
               (#sub)
                -
               |
                in(#parent) gap(100); // super view with explicit standard gaps
          """
        ,
          [
            '#parent[top] + 100 == #sub[top]'
            '#sub[bottom] + 100 == #parent[bottom]'
          ]

    parse """
            @h |-(#sub1)-(#sub2)-| in(#parent) outer-gap(10); // outer-gap
          """
        ,
          [
            '#parent[left] + 10 == #sub1[left]'
            '#sub1[right] + [hgap] == #sub2[left]'
            '#sub2[right] + 10 == #parent[right]'
          ]

    parse """
            @h |-(#sub1)-(#sub2)-| in(#parent) gap(8) outer-gap([baseline]); // outer-gap
          """
        ,
          [
            '#parent[left] + [baseline] == #sub1[left]'
            '#sub1[right] + 8 == #sub2[left]'
            '#sub2[right] + [baseline] == #parent[right]'
          ]

    expectError '@h |-(#box]-;'






  # Points
  # --------------------------------------------------

  describe '/* Points */', ->

    parse """
            @v <100>(#sub)<300>; // point containment
          """
        ,
          [
            '100 == #sub[top]'
            '#sub[bottom] == 300'
          ]

    parse """
            @h < "col1"[center-x] + 20 >-(#box1)-< ::window[center-x] >; // point containment
          """
        ,
          [
            '"col1"[center-x] + 20 + [hgap] == #box1[left]'
            '#box1[right] + [hgap] == ::window[center-x]'
          ]

    parse """
            @h < [line] >-(#box1)-(#box2); // point containment
          """
        ,
          [
            '[line] + [hgap] == #box1[left]'
            '#box1[right] + [hgap] == #box2[left]'
          ]

    parse """
            @h (#btn1)-<::window[center-x]>-(#btn2) gap(8); // point in alignment
          """
        ,
          [
            '#btn1[right] + 8 == ::window[center-x]'
            '::window[center-x] + 8 == #btn2[left]'
          ]

    parse """
            @h (#btn1)-<::window[center-x]>-(#btn2) gap(8) chain-top chain-width(==); // chains ignore points
          """
        ,
          [
            '#btn1[right] + 8 == ::window[center-x]'
            '::window[center-x] + 8 == #btn2[left]'
            '#btn1[top] == #btn2[top]'
            '#btn1[width] == #btn2[width]'
          ]

    parse """
            @h (#btn1)-<"col3"[left]>
                       <"col4"[right]>-(#btn2)
              gap(8);
              // consecutive points are not equalized
          """
        ,
          [
            '#btn1[right] + 8 == "col3"[left]'
            '"col4"[right] + 8 == #btn2[left]'
          ]




    parse """
            @h (#btn1)-<&[-other-place]>
                       < &[center-x] >-(#btn2)
              gap(&[gap]);
              // this scoped
          """
        ,
          [
            '#btn1[right] + &[gap] == &[-other-place]'
            '&[center-x] + &[gap] == #btn2[left]'
          ]

    parse """
            @h (#btn1)-< (.box .foo:bar:next .black)[center-x] >
                       < (.box ! .foo:bar:next .black)[left] >-(#btn2)
              gap(&[gap]);
              // complex selectors
          """
        ,
          [
            '#btn1[right] + &[gap] == (.box .foo:bar:next .black)[center-x]'
            '(.box ! .foo:bar:next .black)[left] + &[gap] == #btn2[left]'
          ]

    parse """
            @h | - (#btn1) - <&[right]>
                       < &[right] > - (#btn2) - |
              gap(&[gap])
              outer-gap(&[outer-gap])
              in(&);
              // this scoped
          """
        ,
          [
            '&[left] + &[outer-gap] == #btn1[left]'
            '#btn1[right] + &[gap] == &[right]'
            '&[right] + &[gap] == #btn2[left]'
            '#btn2[right] + &[outer-gap] == &[right]'
          ]









  # Cushions
  # --------------------------------------------------

  describe '/* Cushions */', ->

    parse """
            @h (#b1)~(#b2); // simple cushion
          """
        ,
          [
            "#b1[right] <= #b2[left]"
          ]

    parse """
            @h (#b1)~-~(#b2)~100~(#b3); // cushions w/ gaps
          """
        ,
          [
            "#b1[right] + [hgap] <= #b2[left]"
            "#b2[right] + 100 <= #b3[left]"
          ]

    parse """
            @h |~(#sub)~2~| in(#parent); // super view with cushions
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
            @v (#sub(==100)); // single predicate
          """
        ,
          [
            '#sub[height] == 100'
          ]

    parse """
            @v (#box(<=100!required,>=30!strong100)); // multiple predicates w/ strength & weight
          """
        ,
          [
            '#box[height] <= 100 !required'
            '#box[height] >= 30 !strong100'
          ]

    parse """
            @h (#b1(<=100))(#b2(==#b1)); // connected predicates
          """
        ,
          [
            '#b1[width] <= 100'
            '#b2[width] == #b1[width]'
            '#b1[right] == #b2[left]'
          ]

    parse """
            @h ("b1"(<=100)) ("b2"(=="b1")); // virtuals
          """
        ,
          [
            '"b1"[width] <= 100'
            '"b2"[width] == "b1"[width]'
            '"b1"[right] == "b2"[left]'
          ]

    parse """
            @h (#b1( <=100 , ==#b99 !99 ))(#b2(>= #b1 *2  !weak10, <=3!required))-100-(.b3(==200)) !medium200; // multiple, connected predicates w/ strength & weight
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
            @h (#b1(==[colwidth])); // predicate with constraint variable
          """
        ,
          [
            '#b1[width] == [colwidth]'
          ]

    parse """
            @h (#b1(==#b2[height])); // predicate with explicit view variable
          """
        ,
          [
            '#b1[width] == #b2[height]'
          ]


  # Chains
  # --------------------------------------------------

  describe '/* Chains */', ->

    parse """
            @h (#b1)(#b2) chain-height chain-width(250); // basic equality chains
          """
        ,
          [
            '#b1[right] == #b2[left]'
            '#b1[height] == #b2[height]'
            '#b1[width] == 250 == #b2[width]'
          ]

    parse """
            @h (#b1)(#b2)(#b3) chain-width(==[colwidth]!strong,<=500!required); // mutliple chain predicates
          """
        ,
          [
            '#b1[right] == #b2[left]'
            '#b2[right] == #b3[left]'
            '#b1[width] == [colwidth] == #b2[width] == [colwidth] == #b3[width] !strong'
            '#b1[width] <= 500 >= #b2[width] <= 500 >= #b3[width] !required'
          ]

    parse """
            @v (#b1)(#b2)(#b3)(#b4) chain-width(==!weak10) chain-height(<=150>=!required) !medium; // explicit equality & inequality chains
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
            @v (#b1(==100!strong)) chain-centerX chain-width( 50 !weak10); // single view w/ equality chains
          """
        ,
          [
            '#b1[height] == 100 !strong'
          ]

    parse """
            @v |-8-(#b1(==100!strong))(#b2)-8-| in(#panel) chain-centerX( #panel[centerX] !required) chain-width(>=50=<!weak10); // adv w/ super views & chains
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
            @v |-(#b1)-(#b2)-| in("panel") gap("zone"[col-size]) outer-gap("outer-zone"[row-size]) chain-centerX( "panel"[centerX] !required); // adv w/ virtuals
          """
        ,
          [
            '"panel"[top] + "outer-zone"[row-size] == #b1[top]'
            '#b1[bottom] + "zone"[col-size] == #b2[top]'
            '#b2[bottom] + "outer-zone"[row-size] == "panel"[bottom]'
            '#b1[centerX] == "panel"[centerX] == #b2[centerX] !required'
          ]


  # Names
  # --------------------------------------------------

  describe '/* Names */', ->

    parse """
            @h (#b1)-100-(#b2)-(#b3)-(#b4) gap(#box1[width]) name(button-layout) !strong; // view variable standard gap
          """
        ,
          [
            "#b1[right] + 100 == #b2[left] name(button-layout) !strong"
            "#b2[right] + #box1[width] == #b3[left] name(button-layout) !strong"
            "#b3[right] + #box1[width] == #b4[left] name(button-layout) !strong"
          ]

    parse """
            @h (#b1)-100-(#b2)-(#b3)-(#b4) gap(#box1[width]) !strong name(button-layout); // view variable standard gap
          """
        ,
          [
            "#b1[right] + 100 == #b2[left] name(button-layout) !strong"
            "#b2[right] + #box1[width] == #b3[left] name(button-layout) !strong"
            "#b3[right] + #box1[width] == #b4[left] name(button-layout) !strong"
          ]

    parse """
            @v (#b1)(#b2)(#b3)(#b4) chain-width(==) chain-height(<=150>=!required) name(bob) !medium; // explicit equality & inequality chains
          """
        ,
          [
            '#b1[bottom] == #b2[top] name(bob) !medium'
            '#b2[bottom] == #b3[top] name(bob) !medium'
            '#b3[bottom] == #b4[top] name(bob) !medium'
            '#b1[width] == #b2[width] == #b3[width] == #b4[width] name(bob)'
            '#b1[height] <= 150 >= #b2[height] <= 150 >= #b3[height] <= 150 >= #b4[height] name(bob) !required'
          ]


  # Splat
  # --------------------------------------------------

  describe '/* Splats */', ->

    # @h Just splats + gaps
    # -----------------------------

    parse """
            @h (.box)...;
          """
        ,
          {
            statements: [
                ".box { &[right] == &:next[left]; }"
              ]
            selectors: ['.box']
          }

    parse [
            """
              @h (.box)-10-...;
            """,
            """
              @h (.box)-... gap(10);
            """
          ]
        ,
          {
            statements: [
                ".box { &[right] + 10 == &:next[left]; }"
              ]
            selectors: ['.box']
          }

    parse [
            """
              @h (.box)-... gap("col-1"[width]);
            """,
            """
              @h (.box)-"col-1"[width]-...;
            """
          ]
        ,
          {
            statements: [
                """.box { &[right] + "col-1"[width] == &:next[left]; }"""
              ]
            selectors: ['.box']
          }

    # @v Just splats + cushions
    # -----------------------------

    parse """
            @v (.box)~...;
          """
        ,
          {
            statements: [
                ".box { &[bottom] <= &:next[top]; }"
              ]
            selectors: ['.box']
          }

    parse [
            """
              @v (.box)
                ~10~...;
            """,
            """
              @v (.box) ~-~ ... gap(10);
            """
          ]
        ,
          {
            statements: [
                ".box { &[bottom] + 10 <= &:next[top]; }"
              ]
            selectors: ['.box']
          }

    parse [
            """
              @v
                ( .box )
                ~-~
                ...

                gap("col-1"[width]);
            """,
            """
              @v
                ( .box )
                  ~ "col-1"[width] ~
                  ...;
            """
          ]
        ,
          {
            statements: [
                """.box { &[bottom] + "col-1"[width] <= &:next[top]; }"""
              ]
            selectors: ['.box']
          }

  # Splats + other layout items
  # -----------------------------

  parse """ // :first & :last injection w/ parans
          @h (& .nav) (& .box)... (& .aside)
        """
      ,
        {
          statements: [
              "(& .box) { &[right] == &:next[left]; }"
              "(& .nav)[right] == ((& .box):first)[left]"
              "((& .box):last)[right] == (& .aside)[left]"
            ]
          selectors: ['(& .nav)','(& .box)','(& .aside)']
        }

  parse """
          @h (#nav) (.box)... (#aside)
        """
      ,
        {
          statements: [
              ".box { &[right] == &:next[left]; }"
              "#nav[right] == .box:first[left]"
              ".box:last[right] == #aside[left]"
            ]
          selectors: ['#nav','.box','#aside']
        }

  parse """
          @h | ~ (.box:even)... -16- (.box:odd)... ~ | in(&)
        """
      ,
        {
          statements: [
              ".box:even { &[right] == &:next[left]; }"
              "&[left] <= .box:even:first[left]"
              ".box:odd { &[right] == &:next[left]; }"
              ".box:even:last[right] + 16 == .box:odd:first[left]"
              ".box:odd:last[right] <= &[right]"
            ]
          selectors: ['.box:even','.box:odd']
        }

  parse """
          @v |
             (.box)...
             |
               in(::window)
        """
      ,
        {
          statements: [
              ".box { &[bottom] == &:next[top]; }"
              "::window[top] == .box:first[top]"
              ".box:last[bottom] == ::window[bottom]"
            ]
          selectors: ['.box']
        }

  parse """
          @v |
             (#nav)
             ~20~
             (.box)
               -[post-gap]-
               ...
             ~20~
             (#footer)
             |
               in(::window)
        """
      ,
        {
          statements: [
              "::window[top] == #nav[top]"
              ".box { &[bottom] + [post-gap] == &:next[top]; }"
              "#nav[bottom] + 20 <= .box:first[top]"
              ".box:last[bottom] + 20 <= #footer[top]"
              "#footer[bottom] == ::window[bottom]"
            ]
          selectors: ['#nav','.box','#footer']
        }






  # Selectors
  # --------------------------------------------------

  describe '/* Selectors */', ->

    parse """
            @h | (button.selected:first) (button.selected:last) | in(header.test:boob)
          """
        ,
          {
            statements: [
                "header.test:boob[left] == button.selected:first[left]",
                "button.selected:first[right] == button.selected:last[left]",
                "button.selected:last[right] == header.test:boob[right]"
              ]
            selectors: ['button.selected:first', 'button.selected:last']
          }

    parse """
            @v | (&) | in(::window)
          """
        ,
          {
            statements: [
                "::window[top] == &[top]",
                "&[bottom] == ::window[bottom]"
              ]
            selectors: ['&']
          }

    parse """ // complex selectors
            @v (& "Zone")-(#box "1")-(.class"a")-(&.class"q-1")-(& > .class .class2"_fallout");
          """
        ,
          {
            statements: [
                '(& "Zone")[bottom] + [vgap] == (#box "1")[top]'
                '(#box "1")[bottom] + [vgap] == .class"a"[top]'
                '.class"a"[bottom] + [vgap] == &.class"q-1"[top]'
                '&.class"q-1"[bottom] + [vgap] == (& > .class .class2"_fallout")[top]'
              ]
            selectors: ['(& "Zone")', '(#box "1")', '.class"a"', '&.class"q-1"', '(& > .class .class2"_fallout")']
          }

    parse """
            @v | (&:next .featured article .title"zone") | in(& > .class .class2"_fallout")
          """
        ,
          {
            statements: [
                '(& > .class .class2"_fallout")[top] == (&:next .featured article .title"zone")[top]'
                '(&:next .featured article .title"zone")[bottom] == (& > .class .class2"_fallout")[bottom]'
              ]
            selectors: [
                '(&:next .featured article .title"zone")'
              ]
          }

    parse """ // comma seperated scoped zones
            @v |(&"zone2", &"zone1")| in(&)
          """
        ,
          {
            statements: [
                '&[top] == (&"zone2", &"zone1")[top]'
                '(&"zone2", &"zone1")[bottom] == &[bottom]'
              ]
            selectors: [
                '(&"zone2", &"zone1")'
              ]
          }
