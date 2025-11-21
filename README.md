# mndoc

[![license](https://img.shields.io/badge/license-BSD-lightgray.svg)](https://opensource.org/license/bsd)
[![Release](https://img.shields.io/github/v/release/mittelmark/mndoc.svg?label=current+release)](https://github.com/mittelmark/mndoc/releases)
![Downloads](https://img.shields.io/github/downloads/mittelmark/mndoc/total)
![Commits](https://img.shields.io/github/commits-since/mittelmark/mndoc/latest)
[![DocuHTML](https://img.shields.io/badge/DocuHTML-blue)](http://htmlpreview.github.io/?https://github.com/mittelmark/mndoc/blob/master/mndoc/mndoc.html)
[![DocuPDF](https://img.shields.io/badge/DocuPDF-blue)](https://github.com/mittelmark/mndoc/releases/latest/download/mndoc.pdf)

Markdown to HTML converter and source code documentation tool using embedded Markdown for programming
languages supporting either multiline comments or at least the # character for comments.

* Extended version of the Tcllib package mkdoc
* Tcl application for document conversion from Markdown to HTML
* Tcl application to extract Markdown documentation from source code tools
* Tcl library for  programmers to accomplish both things above from within the
  Tcl programming language
* Features added to mndoc in comparison to mkdoc
    * stand-alone simplified installation using shell script
    * file size for install less than 150kb
    * support for Syntax highlighting using Javascript highlighters
    * support for embedded LaTeX equations using mathjax
    * header, footer support
    * base64 encoding of local images, stylsheets and Javascript files for 
      creating standalone applications during conversion from Markdown
      or in already existing HTML files
    * support for image attributes like width
    * suppport for styling via YAML header
    * omission of HTML header and footer if requested
    * refresh option for development  

So the mndoc package/application can be as well  used to  convert  Markdown  code into HTML  optionally  adding
header, footer, stylesheets and Javascript code. The latter can be used to add
syntax   highlighting   for   instance   using   the [Highlight.js syntax   highlighter](https://github.com/highlightjs).
Since version 0.9.0 it as well supports embedding LaTeX equations using the
[MathJax Javascript library](https://www.mathjax.org/)

* current code and manuals:  [mndoc.zip](https://github.com/mittelmark/mndoc/archive/refs/heads/main.zip)
* Manual page [mndoc.html](http://htmlpreview.github.io/?https://github.com/mittelmark/mndoc/blob/master/mndoc/mndoc.html)
* Manual page as PDF [mndoc.pdf](https://github.com/mittelmark/mndoc/releases/latest/download/mndoc.pdf)

Please note that Mathjax and Hilightjs do not work in these manuals, there only work in HTML page.

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

On Linux, MacOS or Windows  with  installed  Msys2, Cygwin or WSL   download the
latest  _mndoc-VERSION.bin_ file  (100-130kb in size), rename the bin file to
_mndoc_  and  copy  the  file  to a  folder  belonging  to your  _PATH_  variable.
Thereafter make the file executable and check that it is correctly  installed.

There is as well an install script which installs _mndoc_ 
into `~/.local/bin`. You can execute it like this:

```
bash -c "$(curl -fsSL https://github.com/mittelmark/mndoc/releases/latest/download/install-mndoc.sh)"
```

## Changes in Comparison to the Tcllib mkdoc Package

- adding header and footer support
- adding javascript (single and multiple file support)
- adding code highlight support [highligthjs](https://highlightjs.org/)
- adding equation support using [MathJax](https://www.mathjax.org/)
- adding css support for multiple files
- adding standalone  binary  mndoc.bin  with  embedded  Tcllib  packages  for
  document conversion
- adding support for embedding local images,  stylesheet and Javascript  code
  using base64 encoding
- adding support for refresh option  
- adding support for inlining local images and stylesheets into existing HTML files  
- adding support for TODO lists
- adding support for YAML headers and styles
- adding support for image attributes

## ChangeLog

- 2019-11-19 Release 0.1
- 2019-11-22 Adding direct conversion from Markdown files to HTML files.
- 2019-11-27 Documentation fixes
- 2019-11-28 Kit version
- 2019-11-28 Release 0.2 to fossil
- 2019-12-06 Partial R-Roxygen/Markdown support
- 2020-01-05 Documentation fixes and version information
- 2020-02-02 Adding include syntax
- 2020-02-26 Adding stylesheet option --css 
- 2020-02-26 Adding files pandoc.css and dgw.css
- 2020-02-26 Making standalone file using pkgDeps and mk_tm
- 2020-02-26 Release 0.3 to fossil
- 2020-02-27 support for \_\_DATE\_\_, \_\_PKGNAME\_\_, \_\_PKGVERSION\_\_ macros  in Tcl code based on package provide line
- 2020-09-01 Roxygen2 plugin
- 2020-11-09 argument --run supprt
- 2020-11-10 Release 0.4
- 2020-11-11 command line option  --run with seconds
- 2020-12-30 Release 0.5 (rox2md @section support with preformatted, emph and strong/bold)
- 2022-02-11 Release 0.6.0 
    - parsing yaml header
    - workaround for images
    - making standalone using tpack.tcl [mkdoc-0.6.bin](https://github.com/mittelmark/DGTcl/blob/master/bin/mkdoc-0.6.bin)
    - terminal help update and cleanup
    - moved to Github in Wiki
    - code cleanup
- 2022-04-XX Release 0.7.0
    - removing features to simplify the code, so removed plugin support, underline placeholder and sorting facilitites to reduce code size
    - creating tcllib compatible manual page
    - aku changes and fixes to include mndoc into tcllib's infrastructure
    - splitting of command line app to the apps folder
    - adding hook package requirement (benefit?)
    - changing license to BSD
- 2023-09-07 Release 0.7.1 - image tag fix 
- 2023-11-17 Release 0.8.0 
    - removed hook package, sorry do not understand what it is doing
       and what is the benefit and I could not extend my code with this 
    - adding --header and --footer options
    - adding --javascript option, single oder multiple files
    - extending --css option, single or multiple files
    - support for syntax highlighting using hilightjs Javascript
    - fixing issues with triple backtick codes, by fixing markdown package
       (issue is done on tcllib)
    - adding example file in examples to show syntax highlighting
    - adding Makefile to build standalone application using tpack (80kb)
- 2024-11-16 Release 0.9.0
     - support for mathjax
- 2024-11-28 Release 0.10.0
    - support for refresh option to autorefresh a HTML page 
    - removed run support, use pantcl instead
    - fixing issues with greater, lower and quote signs in code fragments
    - removing inlining external javascript files into HTML output
    - adding --base64 option to inline local images and css files
- 2024-11-28 Release 0.10.1
    - minor documentation fix
- 2024-12-24 Release 0.10.2
    - amp-amp fix for source code blocks
- 2025-01-04 Release 0.11.0
    - Tcl 9 support
- 2025-01-04 Release 0.11.1
    - fixing outfile ending with Tmd, Rmd etc seen as HTML files
- 2025-01-18 Release 0.11.2
    - fixing inline multiple images on the same line
- 2025-01-26 Release 0.11.3
    - fixing wrong command line argument crash
    - fixing uneven length option list
- 2025-10-16 Release 0.13.0
    - renamed to mndoc with version 0.13.0 to avoid name collisions with
       mkdoc package in tcllib
- 2025-10-23 Release 0.14.0
    - adding support for inlining local images and stylesheets into exisiting
       HTML files
    - adding option --bodyonly to omit HTML header and footer as well as body tag
    - support for style section in YAML header for instance to install and use Bunny fonts
    - support for simple todo lists
    - support for image attributes like width
- 2025-10-26 Release 0.14.1
    - file application cache file right fix for multiple users on the same machine try to run mndoc
- 2025-10-30 Release 0.14.2
    - mathjax inline equations with $ equation $ to avoid backslash issues
- 2025-11-21 Release 0.15.0
    - support for """#' and /**#' to start Markdown blocks and """ */ to end Markdown blocks
       to document for example the Julia language

## TODO's

- [ ] conversion of HTML to HTML with embedding as base 64 data local
    - [x] images (v0.14.0)
    - [x] css files (v.0.14.0)
    - [ ] javascript files
- [x] allow linking of https://european-alternatives.eu/de/produkt/bunny-fonts  (v0.14.0)  

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


  
