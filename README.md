# mndoc

[![license](https://img.shields.io/badge/license-BSD-lightgray.svg)](https://opensource.org/license/bsd)
[![Release](https://img.shields.io/github/v/release/mittelmark/mndoc.svg?label=current+release)](https://github.com/mittelmark/mndoc/releases)
![Downloads](https://img.shields.io/github/downloads/mittelmark/mndoc/total)
![Commits](https://img.shields.io/github/commits-since/mittelmark/mndoc/latest)
[![Docu](https://img.shields.io/badge/Docu-blue)](http://htmlpreview.github.io/?https://github.com/mittelmark/mndoc/blob/master/mndoc/mndoc.html)

Markdown to HTML converter and source code documentation tool using embedded Markdown for programming
languages supporting either multiline comments or at least the # character for comments.

* Extended version of the Tcllib package mkdoc
* Tcl application for document conversion from Markdown to HTML
* Tcl application to extract Markdown documentation from source code tools
* Tcl library for  programmers to accomplish both things above from within the
  Tcl programming language
* Features added to mndoc in comparison to mkdoc
    * support for Syntax highlighting
    * support for embedded LaTeX equations using mathjax
    * header, footer support
    * base64 encoding of local images, stylsheets and Javascript files for 
      creating standalone applications

So the mndoc package/application can be as well  used to  convert  Markdown  code into HTML  optionally  adding
header, footer, stylesheets and Javascript code. The latter can be used to add
syntax   highlighting   for   instance   using   the [Highlight.js syntax   highlighter](https://github.com/highlightjs).
Since version 0.9.0 it as well supports embedding LaTeX equations using the
[MathJax Javascript library](https://www.mathjax.org/)

* current code and manuals:  [mndoc.zip](https://github.com/mittelmark/mndoc/archive/refs/heads/main.zip)
* Manual page [mndoc.html](http://htmlpreview.github.io/?https://github.com/mittelmark/mndoc/blob/master/mndoc/mndoc.html)

Here an example of an embedded mndoc comment for a Python script:

```python
#!/usr/bin/env python3
#' **hw()**
#'  
#' > Function prints "Hello World!" to the terminal!"
#'  
#' > Arguments: 
#'  
#' > - _n_ - how often the string "Hello World!" should be printed, default: 3 
#'  
#' > Returns: None
#'  
#' > Example:
#'  
#' ```
#' hw(5)
#' ```
#'   
def hw(n=3):
    for i in range(0,n):  
       print("Hello World!")
    
```

Markdown  documentation  comments for programming languages which have not the
hash  character  as a  comment  character  can be  embedded  using  multliline
comments. Here an example for a C or C++ programm:

```c
/*
#' **void hw(int n);**
#' ...
*/
void hw(int n) {
    int i = 0;
    for (i = 0 ; i < n; i=i+1) {
        printf("Hello World!\n");
    }
}
```   

A more extended example can be seen within the script
[mndoc/mndoc.tcl](https://github.com/mittelmark/mndoc/blob/main/mndoc/mndoc.tcl)
itself. 

These comments are used to create the manual which can be seen here: 
[mndoc.html](http://htmlpreview.github.io/?https://github.com/mittelmark/mndoc/blob/master/mndoc/mndoc.html).

An example using syntax hilighting can be seen here (seems not to work in preview mode):

* [hilight.md](https://github.com/mittelmark/mndoc/blob/master/examples/hilight.md)
* [hilight.html](http://htmlpreview.github.io/?https://github.com/mittelmark/mndoc/blob/master/examples/hilight.html).

An example using equation embedding can be seen here (seems not to work in preview mode):

* [equations.md](https://github.com/mittelmark/mndoc/blob/master/examples/equations.md)
* [equations.html](http://htmlpreview.github.io/?https://github.com/mittelmark/mndoc/blob/master/examples/equations.html).

## Installation

On Linux, MacOS and on Windows with installed Msys2 or Cyvwin download the latest
[mndoc-VERSION.bin](https://github.com/mittelmark/mndoc/releases) binary (90kb in size), rename
it to mndoc and copy the file to a folder belonging to your PATH variable. 
Thereafter make the file executable and check that it is correctly installed like
this:

```
$ mndoc --version
0.13.0
```

## Installation

On Linux, MacOS and on Windows  with  installed  Msys2, Cygwin or WSL   download the
latest  _mndoc-VERSION.bin_ file  (100-130kb in size), rename the bin file to
_mndoc_  and  copy  the  file  to a  folder  belonging  to your  _PATH_  variable.
Thereafter make the file executable and check that it is correctly  installed.

There is as well an install script which installs _mndoc_ 
into `~/.local/bin`. You can execute it like this:

```
bash -c "$(curl -fsSL https://github.com/mittelmark/mndoc/releases/latest/download/install-mndoc.sh)"
```

## Changes in Comparison to the Tcllib Package

- adding header and footer support
- adding javascript (single and multiple file support)
- adding code highlight support [highligthjs](https://highlightjs.org/)
- adding equation support using [MathJax](https://www.mathjax.org/)
- adding css support for multiple files
- adding standalone  binary  mndoc.bin  with  embedded  Tcllib  packages  for
  document conversion
- adding support for embedding  local images,  stylesheet and Javascript  code
  using base64 encoding
- adding support for refresh option  
- adding support for inlining local images and stylesheets into existing HTML files  

## TODO's

- [ ] conversion of HTML to HTML with embedding as base 64 data local
    - [x] images (v0.14.0)
    - [x] css files (v.0.14.0)
    - [ ] javascript files
- [ ] allow linking of https://european-alternatives.eu/de/produkt/bunny-fonts    

## Author

@ 2020-2025 - Detlef  Groth,  University  of  Potsdam,  Germany  -
  dgroth(at)uni(minus)potsdam(dot)de

## License


```
BSD 3-Clause License

Copyright (c) 2020-2025, Detlef Groth, University of Potsdam, Germany

All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its
   contributors may be used to endorse or promote products derived from
   this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
```


  
