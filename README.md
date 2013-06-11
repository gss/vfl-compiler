VFL Compiler [![Build Status](https://travis-ci.org/the-gss/vfl-compiler.png?branch=master)](https://travis-ci.org/the-gss/vfl-compiler)
=============

This library compiles Grid flavored [Visual Format Language](http://developer.apple.com/library/ios/#documentation/UserExperience/Conceptual/AutolayoutPG/Articles/formatLanguage.html) from [Cocoa Autolayout](http://developer.apple.com/library/ios/#documentation/UserExperience/Conceptual/AutolayoutPG/Articles/formatLanguage.html), into Grid flavored [CCSS](http://citeseer.ist.psu.edu/viewdoc/summary?doi=10.1.1.101.4819) statements.


# API

> Below examples omit the vendor prefix., so `@horizontal` is lazy-hand for `@-gss-horizontal`

#### Horizontal Connections with a Gap

This examples uses a standard horizontal gap:

`@horizontal [#button]-[#input];`

to explicitly define the gap:

`@horizontal [#button]-8-[#input];`

which is equivalent to the CCSS statement:

`#button[right] + 8 == #input[left]`

![Grid flavored VFL: standard gap](http://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/AutolayoutPG/Art/standardSpace.png)

#### Flush Connection

`@horizontal [#maroonView][#oceanView];`

![](http://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/AutolayoutPG/Art/flushViews.png)

#### Vertical Layout

Use `vertical` instead of `horizontal`.

`@vertical [#topField]-[#bottomField]`

![](http://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/AutolayoutPG/Art/verticalLayout.png)

#### Width Constraint

`@horizontal [#button(>=50)];`

![](http://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/AutolayoutPG/Art/widthConstraint.png)

#### Multiple Predicates

`@horizontal [#flexibleButton(>=70,<=100)];`

![](http://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/AutolayoutPG/Art/multiplePredicates.png)

#### Connection to Superview

`@horizontal |-50-[#purple]-50-| in(#box);`

![](http://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/AutolayoutPG/Art/connectionToSuperview.png)

#### Equal Widths

`@horizontal [#button1(==#button2)];`

![](http://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/AutolayoutPG/Art/equalWidths.png)

#### A Complete Line of Layout

`@horizontal |-[#find]-[#findNext]-[#findField(>=20)]-|;`

![](http://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/AutolayoutPG/Art/completeLayout.png)

#### Cushion Connections

Cushion connections, those with `~`, are essentially single dimensional non-overlapping constraints.

To ensure `#panelA`s right edge doesn't go passed `#panelB`s left edge:

`@horizontal [#panelA]~[#panelB];`

which is equivalent to the following CCSS:

`#panelA[right] <= #panelB[left]`

#### Constraining the Standard Gap

To set and/or constrain the gap used in the layout connections, use the `hgap` or `vgap` variables in regular GSS.  

For example, to define a layout where the horizontal gap prefers to be 10% of a button's width, but never below 100px:

```
[hgap] == #b1[width]/10 !weak;
[hgap] >= 100 !required;

@horizontal [#b1]-[#b2]-[#b3]-[#b4];
```

This is where the powers of CCSS and VFL come together for pure awesome.

----------------------

The above images are from Cocoa Auto Layout Guide and are copyright of Apple.

