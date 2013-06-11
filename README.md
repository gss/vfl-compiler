VFL Compiler [![Build Status](https://travis-ci.org/the-gss/vfl-compiler.png?branch=master)](https://travis-ci.org/the-gss/vfl-compiler)
=============

This library compiles GSS flavored [Visual Format Language](http://developer.apple.com/library/ios/#documentation/UserExperience/Conceptual/AutolayoutPG/Articles/formatLanguage.html) from [Cocoa Autolayout](http://developer.apple.com/library/ios/#documentation/UserExperience/Conceptual/AutolayoutPG/Articles/formatLanguage.html), into GSS flavored [CCSS](http://citeseer.ist.psu.edu/viewdoc/summary?doi=10.1.1.101.4819) statements.  


# API

#### Horizontal layout with standard gap

`@h [#button]-[#input]`

![GSS flavored VFL: standard gap](http://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/AutolayoutPG/Art/standardSpace.png)

compiles to

`#button[right] + [hgap] == #input[left]`

#### Vertical Layout with explicit gap

`@v [topField]-10-[bottomField]`

![](http://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/AutolayoutPG/Art/verticalLayout.png)

#### Flush Views

`@h [maroonView][oceanView]`

![](http://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/AutolayoutPG/Art/flushViews.png)

#### Width Constraint

`@h [#button(>=50)]`

![](http://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/AutolayoutPG/Art/widthConstraint.png)

#### Multiple Predicates

`@h [#flexibleButton(>=70,<=100)]`

![](http://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/AutolayoutPG/Art/multiplePredicates.png)

### Connection to Superview

`@h |-50-[#message]-50-| in(#panel)`

![](http://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/AutolayoutPG/Art/connectionToSuperview.png)

#### Equal Widths

`@h [#button1(==#button2)]`

![](http://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/AutolayoutPG/Art/equalWidths.png)

#### A Complete Line of Layout

`@h |-[#find]-[#findNext]-[#findField(>=20)]-|`

![](http://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/AutolayoutPG/Art/completeLayout.png)

----------------------

The above images are from Cocoa Auto Layout Guide and are copyright of Apple.

