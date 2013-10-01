codemodels
===========

codemodels is a library to create and manipulate models. A serialization format (based on JSON) is defined.

It is based on [RGen](http://github.com/mthiede/rgen) and it supportes the conversion of EMF models through [emf_jruby](http://github.com/ftomassetti/emf_jruby).

There are different gems which transform source code in models of the code. Currently they are:
* [html-lightmodels](http://github.com/ftomassetti/html-lightmodels)
* [codemodels-java](http://github.com/ftomassetti/codemodels-java)
* [js-lightmodels](http://github.com/ftomassetti/js-lightmodels)
* [properties-lightmodels](http://github.com/ftomassetti/properties-lightmodels)
* [codemodels-ruby](http://github.com/ftomassetti/codemodels-ruby)
* [xml-lightmodels](http://github.com/ftomassetti/xml-lightmodels)

Therefore it can be used to perform analysis on different languages.

Features
========

It handles also the case in which different languages are hosted in the same file (for example a Javascript script inside an HTML page).

Most of the parsers permit also to associate each node with a precise point in the source code, so thath they could be used to implement layout-preserving refactoring.
