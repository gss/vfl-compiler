VFL Compiler [![Build Status](https://travis-ci.org/the-gss/vfl-compiler.png?branch=master)](https://travis-ci.org/the-gss/vfl-compiler)
=============

This library compiles GSS flavored [Visual Format Language](http://developer.apple.com/library/ios/#documentation/UserExperience/Conceptual/AutolayoutPG/Articles/formatLanguage.html) from [Cocoa Autolayout](http://developer.apple.com/library/ios/#documentation/UserExperience/Conceptual/AutolayoutPG/Articles/formatLanguage.html), into GSS flavored [CCSS](http://citeseer.ist.psu.edu/viewdoc/summary?doi=10.1.1.101.4819) statements.  


# API

> Below examples omit the vendor prefix.  so `@horizontal` is shorthand for `@-gss-horizontal`

#### Horizontal connections with standard gap

`@horizontal [#button]-[#input];`

![GSS flavored VFL: standard gap](http://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/AutolayoutPG/Art/standardSpace.png)

compiles to

`#button[right] + [hgap] == #input[left]`

#### Vertical Layout with explicit gap

`@vertical [#topField]-10-[#bottomField]`

![](http://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/AutolayoutPG/Art/verticalLayout.png)

#### Flush Views

`@horizontal [#maroonView][#oceanView];`

![](http://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/AutolayoutPG/Art/flushViews.png)

#### Width Constraint

`@horizontal [#button(>=50)];`

![](http://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/AutolayoutPG/Art/widthConstraint.png)

#### Multiple Predicates

`@horizontal [#flexibleButton(>=70,<=100)];`

![](http://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/AutolayoutPG/Art/multiplePredicates.png)

### Connection to Superview

`@horizontal |-50-[#message]-50-| in(#panel);`

![](http://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/AutolayoutPG/Art/connectionToSuperview.png)

#### Equal Widths

`@horizontal [#button1(==#button2)];`

![](http://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/AutolayoutPG/Art/equalWidths.png)

#### A Complete Line of Layout

`@horizontal |-[#find]-[#findNext]-[#findField(>=20)]-|;`

![](http://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/AutolayoutPG/Art/completeLayout.png)

#### Cushion connections

Cushion connections, those with `~`, are essentially single dimensional non-overlapping constraints.

To ensure `#panelA`s right edge doesn't go passed `#panelB`s left edge:

`@horizontal [#panelA]~[#panelB];`

compiles tp

`#panelA[right] <= #panelB[left]`

----------------------

The above images are from Cocoa Auto Layout Guide and are copyright of Apple.

