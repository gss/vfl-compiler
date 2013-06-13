VFL Compiler [![Build Status](https://travis-ci.org/the-gss/vfl-compiler.png?branch=master)](https://travis-ci.org/the-gss/vfl-compiler)
=============

This library compiles Grid flavored VFL ([Visual Format Language](http://developer.apple.com/library/ios/#documentation/UserExperience/Conceptual/AutolayoutPG/Articles/formatLanguage.html) from [Cocoa Autolayout](http://developer.apple.com/library/ios/#documentation/UserExperience/Conceptual/AutolayoutPG/Articles/formatLanguage.html)), into Grid flavored CCSS (Greg Badros's [Constraint CSS](http://citeseer.ist.psu.edu/viewdoc/summary?doi=10.1.1.101.4819)) statements.


# API

> Below examples omit the vendor prefix., so `@horizontal` is lazy-hand for `@-gss-horizontal`

## Basics

#### Connections with a Gap

To horizontally seperate `#button` 8px from `#input`:

```
    @horizontal [#button]-8-[#input];
```

which is equivalent to the CCSS statement: `#button[right] + 8 == #input[left]`

![Grid flavored VFL: standard gap](http://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/AutolayoutPG/Art/standardSpace.png)

#### Flush Connection

```
    @horizontal [#maroonView][#oceanView];
```

![](http://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/AutolayoutPG/Art/flushViews.png)

#### Vertical or Horizontal

Use `vertical` instead of `horizontal`.

```
    @vertical [#topField]-8-[#bottomField]
```

which is equivalent to the CCSS statement: `#topField[bottom] + 8 == #bottomField[top]`

![](http://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/AutolayoutPG/Art/verticalLayout.png)

## Standard Gaps

#### Connections with the Standard Gap

To horizontally align 6 boxes with a Standard Gap seperation between each:

```
    @horizontal [#box1]-[#box2]-[#box3]-[#box4]-[#box5]-[#box6];
```

An internal constraint variable is used when a single `-` is used for the gap, the *Standard Gap*.  Horizontal layouts use the `[hgap]` variable, and vertical layouts use the `[vgap]` variable.

#### Defining the Standard Gap

To set the standard gaps, just use them like vanilla [CCSS variables](), like so:

```
    [hgap] == 8;
    @horizontal [#box1]-[#box2]-[#box3]-[#box4]-[#box5]-[#box6];
```

#### Constraining the Standard Gap

For example, to define a layout where the horizontal gap prefers to be 1/16th of the viewports width, but never below 100px:

```
    [hgap] == ::viewport[width]/16 !strong;
    [hgap] >= 100 !required;

    @horizontal [#b1]-[#b2]-[#b3]-[#b4];
```

This is where the powers of CCSS and VFL come together for pure awesome.

## Containment

#### Connection to Superview

```
    @horizontal |-50-[#purple]-50-| in(#box);
```

![](http://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/AutolayoutPG/Art/connectionToSuperview.png)

## Size Predicates

#### Width Predicate

```
    @horizontal [#button(>=50)];
```

![](http://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/AutolayoutPG/Art/widthConstraint.png)

#### Multiple Predicates

```
    @horizontal [#flexibleButton(>=70,<=100)];
```

![](http://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/AutolayoutPG/Art/multiplePredicates.png)

#### Equal Widths

```
    @horizontal [#button1(==#button2)];
```

![](http://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/AutolayoutPG/Art/equalWidths.png)

#### Predicates with Strength & Weight

For more about Constraint Strength & Weight and the Constriant Hierarchy, [check it]().  In a nutshell, stronger constraints completely overcome weaker ones, and required constraints must be satisfied.

Strengths can be weak, medium, strong, required.  Weights can be Integers.

The following Grid flavored VFL:

```
    @horizontal [#b1(==#b2!weak)][#b2(==#b3!medium10)][#b3] !required;
```

is equivalent to the following CCSS:

```
    #b1[width] == #b2[width] !weak;
    #b2[width] == #b3[width] !medium10;
    #b1[right] == #b2[left] !required;
    #b2[right] == #b3[left] !required;
```

> Hardcore Gotcha: The lexographic order of Constraints matters, so take heed.

## Cushions

#### Basic Cushion

Cushion connections, those with `~`, are essentially single dimensional non-overlapping constraints.

To ensure `#panelA`s right edge doesn't go passed `#panelB`s left edge:

```
    @horizontal [#panelA]~[#panelB];
```

which is equivalent to the following CCSS: `#panelA[right] <= #panelB[left]`

#### Cushion with Gap

To cushion by the standard gap:

```
    @horizontal [#panelA]~-~[#panelB];
```

To cushion by an explicit gap:

```
    @horizontal [#panelA]~8~[#panelB];
```

## Demos

#### A Complete Line of Layout

```
@horizontal |-[#find]-[#findNext]-[#findField(>=20)]-|;
```

![](http://developer.apple.com/library/ios/documentation/UserExperience/Conceptual/AutolayoutPG/Art/completeLayout.png)


#### Gotchas & Hardcore Examples

*Tests, bro*.  

----------------------

The above images are from Cocoa Auto Layout Guide and are copyright of Apple.

