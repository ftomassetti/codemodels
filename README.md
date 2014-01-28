codemodels
===========

codemodels is a library to represent and manipulate homogeneously Abstract Syntax Trees of different languages models.

It is based on [RGen](http://github.com/mthiede/rgen) and [RGen-Ext](https://github.com/ftomassetti/rgen_ext). 

There are different gems which transform source code in models of the code. Currently they are:
* [codemodels-html](http://github.com/ftomassetti/codemodels-html)
* [codemodels-java](http://github.com/ftomassetti/codemodels-java)
* [codemodels-js](http://github.com/ftomassetti/codemodels-js)
* [codemodels-properties](http://github.com/ftomassetti/codemodels-properties)
* [codemodels-ruby](http://github.com/ftomassetti/codemodels-ruby)
* [codemodels-xml](http://github.com/ftomassetti/codemodels-xml)

DSLs based on EMF are planned to by supported using [emf_jruby](http://github.com/ftomassetti/emf_jruby).

Codemodels can be used to perform analysis on different languages.

Features
========

It handles also the case in which different languages are hosted in the same file (for example a Javascript script inside an HTML page).

Most of the parsers permit also to associate each node with a precise point in the source code, so thath they could be used to implement layout-preserving refactoring.


[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/ftomassetti/codemodels/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

