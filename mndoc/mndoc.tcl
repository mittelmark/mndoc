# -*- mode: tcl ; fill-column: 80 -*-
##############################################################################
#  Author        : Dr. Detlef Groth
#  Created       : Fri Nov 15 10:20:22 2019
#  Last Modified : <251016.1654>
#
#  Description	 : Command line utility and package to extract Markdown documentation 
#                  from programming code if embedded as after comment sequence #' 
#                  manual pages and installation of Tcl files as Tcl modules.
#                  Copy and adaptation of dgw/dgwutils.tcl
#
#  History       : 2019-11-08 version 0.1
#                  2019-11-28 version 0.2
#                  2020-02-26 version 0.3
#                  2020-11-10 Release 0.4
#                  2020-12-30 Release 0.5 (rox2md)
#                  2022-02-09 Release 0.6
#                  2022-04-XX Release 0.7 (minimal)
#                  2023-09-07 Release 0.7.1 (img tag fix)
#                  2023-11-18 Release 0.8.0 
#                  2024-11-16 Release 0.9.0 Mathjax support
#                  2024-11-21 Release 0.10.0 auto refresh support
#                  2024-11-28 Release 0.10.1 minor documentation fix
#                  2024-12-24 Release 0.10.2 amp-amp fix for source code blocks
#                  2025-01-04 Release 0.11.0 Tcl 9 support
#                  2025-01-18 Release 0.11.2 Fix multiple images include on same line
#                  2025-01-26 Release 0.11.3 Fix invalid argument crash, uneven length option list
#                  2025-10-16 Release 0.12.0 Renamed to mndoc to avoid name class with Tcllib package
#	
##############################################################################
#
# Copyright (c) 2019-2025  Dr. Detlef Groth, E-mail: dgroth((at)uni-potsdam(dot)de
# 
# This library is free software; you can use, modify, and redistribute it for
# any purpose, provided that existing copyright notices are retained in all
# copies and that this notice is included verbatim in any distributions.
# 
# This software is distributed WITHOUT ANY WARRANTY; without even the implied
# warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#
##############################################################################
#' ---
#' title: mndoc::mndoc 0.13.0
#' author: Detlef Groth, University of Potsdam, Germany
#' date: 2025-10-16
#' css: mndoc.css
#' ---
#' 
#' ## NAME
#'
#' **mndoc::mndoc**  - Tcl package and command line application to extract and format 
#' embedded programming documentation from source code files written in Markdown or
#' doctools format and optionally converting it into HTML.
#'
#' ## <a name='toc'></a>TABLE OF CONTENTS
#' 
#'  - [SYNOPSIS](#synopsis)
#'  - [DESCRIPTION](#description)
#'  - [COMMAND](#command)
#'  - [EXAMPLE](#example)
#'  - [FORMATTING](#format)
#'     - [Code Blocks](#code-blocks)
#'     - [Equations](#equations)
#'  - [INSTALLATION](#install)
#'  - [SEE ALSO](#see)
#'  - [CHANGES](#changes)
#'  - [TODO](#todo)
#'  - [AUTHOR](#authors)
#'  - [LICENSE AND COPYRIGHT](#license)
#'
#' ## <a name='synopsis'>SYNOPSIS</a>
#' 
#' Usage as package:
#'
#' ```
#' package require mndoc::mndoc
#' mndoc::mndoc inputfile outputfile ?--css file1.css,file2.css? \
#'    ?--header header.html? ?--footer footer.html? ?--base64 true? \
#'    ?--javascript highlightjs|file1.js,file2.js? ?--mathjax true? ?--refresh 10?
#' ```
#'
#' Usage as command line application for extraction of Markdown comments prefixed with `#'`:
#'
#' ```
#' mndoc inputcodefile outputfile.md ?options?
#' ```
#'
#' Usage as command line application for conversion of Markdown to HTML:
#'
#' ```
#' mndoc inputfile.md outputfile.html ?--css file.css,file2.css --header header.html \
#'   --footer footer.html --javascript highlighjs|filename1,filename2  --mathjax true \
#'   --refresh 10 --base64 true?
#' ```
#'
#' ## <a name='description'>DESCRIPTION</a>
#' 
#' **mndoc::mndoc**  extracts embedded Markdown or doctools documentation from source code files
#' and  as well converts Markdown the output to HTML if desired.
#' The documentation inside the source code must be prefixed with the `#'` character sequence.
#' The file extension of the output file determines the output format. 
#' File extensions can bei either `.md` for Markdown output, `.man` for doctools output or `.html` for html output.
#' The latter requires the tcllib Markdown or the doctools extensions to be installed.
#' If the file extension of the inputfile is *.md* and file extension of the output files is *.html* 
#' there will be simply a conversion from a Markdown to a HTML file.
#'
#' The file `mndoc.tcl` can be as well directly used as a console application. 
#' An explanation on how to do this, is given in the section [Installation](#install).
#'
#' ## <a name='command'>COMMAND</a>
#'
#'  <a name="mndoc"> </a>
#' **mndoc::mndoc** *infile outfile ?--css file.css --header header.html --footer footer.html --mathjax true --refresh 10? *
#' 
#' > Extracts the documentation in Markdown format from *infile* and writes the documentation 
#'    to *outfile* either in Markdown, Doctools  or HTML format. 
#' 
#' > - *infile* - file with embedded markdown documentation
#'   - *outfile* -  name of output file extension
#'   - *--base64 true* should local images and CSS files be included, default: true
#'   - *--css cssfile* if outfile is an HTML file use the given *cssfile*
#'   - *--footer footer.html* if outfile is an HTML file add this footer before the closing body tag
#'   - *--header header.html* if outfile is an HTML file add this header after  the opening body tag
#'   - *--javascript highlighjs|filename1,filename2* if outfile is an HTML file embeds either the hilightjs Javascript hilighter or the given local javascript filename(s) 
#'   - *--mathjax true|false* should there be the MathJax library included, default: false
#'   - *--refresh 0|10* should there be the autorefresh header included only values above 9 are considered, default: 0
#'     
#' > If the file extension of the outfile is either html or htm a HTML file is created. If the output
#'   file has other file extension the documentation after _#'_ comments is simply extracted and stored
#'   in the given _outfile_, *-mode* flag  (one of -html, -md, -pandoc) is not given, the output format
#'   is taken from the file extension of the output file, either *.html* for HTML or *.md* for Markdown format.
#'   This deduction from the filetype can be overwritten giving either `-html` or `-md` as command line flags.
#'   If as mode `-pandoc` is given, the Markdown markup code as well contains the YAML header.
#'   If infile has the extension .md (Markdown) or -man (Doctools) than conversion to html will be performed,
#'   the outfile file extension In this case must be .html.
#'   If output is html a *--css* flag can be given to use the given stylesheet file instead of the default
#'   style sheet embedded within the mndoc code. As well since version 0.8.0 a --header and --footer option
#'   is available to add HTML code at the beginning and at the end of the document.
#'  
#' > Example:
#'
#' > ```
#' package require mndoc::mndoc
#' mndoc::mndoc mndoc.tcl mndoc.html                ## simple HTML page
#' mndoc::mndoc mndoc.tcl mndoc.md                  ## just output a Markdown page
#' mndoc::mndoc mndoc.tcl mndoc.html --refresh 20   ## reload HTML page every twenty seconds
#' mndoc::mndoc mndoc.tcl mndoc.html --mathjax true ## parse inline equations using mathjax library
#' > ```

package require Tcl 8.6-

package require yaml
package require Markdown

package provide mndoc 0.13.0
package provide mndoc::mndoc 0.13.0
namespace eval ::mndoc {
    variable deindent [list \n\t \n "\n    " \n]
    
    variable htmltemplate [string map $deindent {
	<!DOCTYPE html>
	<html>
	<head>
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<meta name="title" content="$document(title)">
	<meta name="author" content="$document(author)">
        $document(refresh)
	<title>$document(title)</title>
        $document(javascript)
        $document(mathjax)
	$style
        $stylejs
	</head>
	<body>
        $document(header)
    }]
    variable footer [string map $deindent {
    $document(footer)
</body>
</html>
}]
    variable htmlstart [string map $deindent {
	<h1 class="title">$document(title)</h1>
	<h2 class="author">$document(author)</h2>
	<h2 class="date">$document(date)</h2>
    }]

    variable mndocstyle [string map $deindent {
	body {
	    margin-left: 10%; margin-right: 10%;
	    font-family: Palatino, "Palatino Linotype", "Palatino LT STD", "Book Antiqua", Georgia, serif;
	    max-width: 90%;
	}
	pre {
	    font-family: Monaco, Consolas, "Liberation Mono", Menlo, Courier, monospace;
	}
    }]
} 

proc ::mndoc::img-replace {line filename} {
    #set line [regsub {<img src="((data:|https?:))} $line "<imgsrc=\"\\1"]
    set imgname [regsub {.*?<img src="([^"]+)".+$} $line "\\1"] ;# "
    if {![regexp {^http} $imgname] && ![regexp {^data:} $imgname]} {
        set ext [regsub {.+\.([a-zA-Z]{2,4})$} $imgname "\\1"]
        set imgname [file normalize [file join [file dirname $filename] $imgname]]
        set mode rb

        if {$ext eq "svg"} {
            set mode r
            set ext "svg+xml"
        }
        if { [catch { set infhi [open $imgname $mode] }] } {
            set line "$line\n\nError: Cannot open '$imgname'!\n\n"
        } else {
            set imgdata [binary encode base64 [read $infhi]]
            close $infhi
            set line [regsub {(.*?)<img src="([^"]+)"} $line "\\1<imgXXXXsrc=\"data:image/$ext;base64, $imgdata\""] ;# "C
        }
    } 
    return $line
}
proc ::mndoc::inline-assets {filename html} {
    set htm ""
    foreach line [split $html "\n"] {
        if {[regexp {<img src="(.+?)"} $line]} {
            while {true} {
                if {![regexp {<img src="(.+?)"} $line]} {
                    break
                }
                set nline [img-replace $line $filename]
                if {$nline eq $line || [regexp {Error:} $nline]} {
                    set line $nline
                    break
                } else {
                    set line $nline
                }
            }
            set line [regsub -all {imgXXXXsrc} $line {img src}]
        } elseif {[regexp -nocase {<link +rel="stylesheet" +href="(.+.css)">} $line match cssfile]} {
            if {[file exists [file join [file dirname $cssfile]]]} {
                set fname [file join [file dirname $filename] $cssfile]
                if [catch {open $fname} infhc] {
                    error "Cannot open $fname: $infhc"
                } else {
                    set css [binary encode base64 [read $infhc]]
                    close $infhc
                    set line "\n<style>\n@import url(\"data:text/css;base64,$css\");\n</style>\n"
                }
            } 
        }
        append htm "$line\n"
    }
    return $htm
}

proc ::mndoc::mndoc {filename outfile args} {
    variable deindent [list \n\t \n "\n    " \n]    
    variable htmltemplate
    variable footer
    variable htmlstart
    variable mndocstyle
    array set document [list title "" author "" css mndoc.css footer "" header "" javascript ""] 
    array set arg [list --css "" --footer "" --header "" --javascript "" \
                   --mathjax false --refresh 0 --base64 true]
    if {! [expr {[llength $args] % 2 == 0}]} {
        return -code error "List mus have an even length of type '--option value'!"
    }
    array set arg $args
    if {[file extension $filename] eq [file extension $outfile] && $filename ne "-"} {
	return -code error "Error: infile and outfile must have different file extensions!"
    }
    set outmode html
    if {[regexp -nocase {(md|nw)$} [file extension $outfile]]} {
        set outmode markup
    }
    set inmode  code
    if {[file extension $filename] in [list .md .man] || $filename eq "-"} {
        set inmode markup
    }
    
    set markdown ""
    if {$filename eq "-"} {
        set infh stdin
    } else {
        if [catch {
            open $filename r
        } infh] {
                return -code error "Cannot open $filename: $infh"
            }
    }
    set flag false
    while {[gets $infh line] >= 0} {
        if {[regexp {^\s*#' +#include +"(.*)"} $line -> include]} {
            if [catch {
                open $include r
            } iinfh] {
                return -code error "Cannot open include file $include: $iinfh"
            } else {
                #set ilines [read $iinfh]
                while {[gets $iinfh iline] >= 0} {
                    # Process line
                    append markdown "$iline\n"
                }
                close $iinfh
            }
        } elseif {$inmode eq "code" && [regexp {^\s*#' ?(.*)} $line -> md]} {
            append markdown "$md\n"
        } elseif {$inmode eq "markup"} {
            append markdown "$line\n"
        }
    }
    if {$filename ne "-"} {
        close $infh
    }
    set yamldict \
        [dict create \
         title  "Documentation [file tail [file rootname $filename]]" \
         author NN \
         date   [clock format [clock seconds] -format "%Y-%m-%d"] \
         css    mndoc.css \
         footer   "" \
         header   "" \
         javascript "" \
         mathjax   "" \
         refresh   ""
         ]

    set mdhtml ""
    set yamlflag false
    set yamltext ""
    set hasyaml false
    set indent ""
    set header $htmltemplate
    set lnr 0
    foreach line [split $markdown "\n"] {
        incr lnr 
        if {$lnr < 5 && !$yamlflag && [regexp {^---} $line]} {
            set yamlflag true
        } elseif {$yamlflag && [regexp {^---} $line]} {
            set hasyaml true
            set yamldict [dict merge $yamldict [yaml::yaml2dict $yamltext]]
            set yamlflag false
        } elseif {$yamlflag} {
            append yamltext "$line\n"
        } else {
            set line [regsub -all {!\[\]\((.+?)\)} $line "<img src=\"\\1\"></img>"]
            append mdhtml "$indent$line\n"
        }
    }
    if {$arg(--css) ne ""} {
        set css ""
        foreach cs [split $arg(--css) ","] {
            append css   "<link rel=\"stylesheet\" href=\"$cs\">"
        }
        dict set yamldict css $css
    }
    set stylejs ""
    if {$arg(--javascript) ne ""} {
        if {$arg(--javascript) eq "highlightjs"} {
            dict set yamldict javascript [string map $deindent {
                                          <link rel="stylesheet" href="https://unpkg.com/@highlightjs/cdn-assets@11.9.0/styles/atom-one-light.min.css">
                                          <script src="https://unpkg.com/@highlightjs/cdn-assets@11.9.0/highlight.min.js"></script>
                                          <!-- tcl must be loaded extra -->
                                          <script src="https://unpkg.com/@highlightjs/cdn-assets@11.9.0/languages/tcl.min.js"></script>
                                          <!-- Initialize highlight.js -->
                                          <script>hljs.highlightAll();</script>
           }]
           set stylejs {<style>
           pre, blockquote pre { background: #fafafa !important; }
           </style>
           }
        } else {
           set jscode ""
           foreach js [split $arg(--javascript) ","] {
               append jscode "<script src=\"$js\"> </script>"
           }
           dict set yamldict javascript $jscode
        }
    }
    if {$arg(--mathjax)} {
        set document(mathjax) {<script id="MathJax-script" async src="https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js"></script>}
        
    } else {
        set document(mathjax) ""
    }
    if {$arg(--refresh) > 9} {
        set document(refresh) "<meta http-equiv=\"refresh\" content=\"$arg(--refresh)\" />"
    } else {
        set document(refresh) ""
    }
    if {$arg(--header) ne ""} {
        if {[file exists $arg(--header)]} {
            set infh [open $arg(--header) r]
            dict set yamldict header [read $infh]
            close $infh
        }
    }
    if {$arg(--footer) ne ""} {
        if {[file exists $arg(--footer)]} {
            set infh [open $arg(--footer) r]
            dict set yamldict footer [read $infh]
            close $infh
        }
    }
    # Regenerate yamltext from the final dict (to report the final CSS reference)
    set yamltext "---\n"
    foreach k [lsort -dict [dict keys $yamldict]] {
        append yamltext "${k}: [dict get $yamldict $k]\n"
    }
    append yamltext "---"
    
    set style <style>$mndocstyle</style>
    if {$outmode eq "html"} {
        if {[dict get $yamldict css] ne "mndoc.css"} {
            # Switch from embedded style to external link
            set style [dict get $yamldict css]
        }
        set html [Markdown::convert $mdhtml]
        if {$arg(--base64)} {
            set html [mndoc::inline-assets $filename $html]
        }
        ## issue in Markdown package?
        set html [string map {&amp;amp; &amp; &amp;lt; &lt;  &amp;gt; &gt; &amp;quot; &quot;} $html]  
        ## fixing curly brace issues in backtick code chunk
        set html [regsub -all "code class='\{" $html {code class='}] 
        set html [regsub -all "code class='(\[^'\]+)\}'" $html {code class='\1'}]
        set out [open $outfile w 0644]
        foreach key [dict keys $yamldict] {
            if {$key == "date"} {
                if {[string is integer [dict get $yamldict $key]]} {
                    set document($key) [clock format [dict get $yamldict $key] -format "%Y-%m-%d"]
                } else {
                    set document($key) [clock format [clock scan [dict get $yamldict $key]] -format "%Y-%m-%d"]
                }
            } elseif {![info exists document($key)] || $document($key) eq ""} {
                set document($key) [dict get $yamldict $key]
            }
        }
        if {![dict exists $yamldict date]} {
            dict set yamldict date [clock format [clock seconds] format "%Y-%m-%d"]
        } 
        set header [subst -nobackslashes -nocommands $header]
        set head ""
        if {$arg(--base64)} {
            set header [mndoc::inline-assets $filename $header]
        }
        puts $out $header
        if {$hasyaml} {
            set start [subst -nobackslashes -nocommands $htmlstart]            
            puts $out $start
        }
        puts $out $html
        set footer [subst -nobackslashes -nocommands $footer]
        puts $out $footer
        close $out
    } else {
        if {$outfile ne "-"} {
            set out [open $outfile w 0644]
            puts $out $yamltext
            puts $out $mdhtml
            close $out
        } else {
            puts $yamltext
            puts $mdhtml
        }
    }
}

proc ::mndoc::main {argv} {
    global argv0
    set valid_args [list --help --version --license --css --header --footer --mathjax \
                    --javascript --refresh --base64]
    set APP $argv0
    if {[regexp {tclmain} $APP]} {
        set APP "tclmain -m mndoc"
    }
set USAGE [string map [list "\n    " "\n"] {
    Usage: __APP__ ?--help|--version|--license? INFILE OUTFILE ?--css file.css? 
                      ?--header header.html? ?--footer footer.html? ?--mathjax true? 
                      ?--javascript JSLIB|JSFile? ?--refresh 10? ?--base64 true?
}]
set HELP [string map [list "\n    " "\n"] {
    mndoc __VERSION__ - code documentation tool to process embedded Markdown markup
                        given after "#'" comments 

    Positional arguments (required):
    
        INFILE  - input file with:
                - embedded Markdown comments: #' Markdown markup
                - pure Markdown code (file.md)
                - if INFILE is given as - input is taken from STDIN

        OUTFILE - output file usually HTML or Markdown file
                - file format is deduced on file extension .html or .md,
                - if OUTFILE is the `-` sign output is written to STDOUT

    Optional arguments:

        --help             - display this help page, and exit
        --version          - display version number, and exit
        --license          - display license information, and exit
        --css CSSFILE      - use the specified CSSFILE instead of internal default 
                             mndoc.css
        --header HTMLFILE  - file with HTML code to be included after the body tag
        --footer HTMLFILE  - file with HTML code to be included before the closing
                             body tag                            
        --base64  BOOL     - should local images, css files and JavaScript files being embedded as base 64 codes, default: true                
        --javascript JSLIB - hightlightjs|file1,file2,... using these Javascript libs / files, default: NULL
        --mathjax BOOL     - Embed the Mathjax Javascript library to add LaTeX formulas, default: false
        --refresh INT      - Create a HTML page which does automatic refreshing after N seconds, default: 0
        
    Examples:

        # create manual page for mndoc.tcl itself 
        __APP__ mndoc.tcl mndoc.html

        # create manual code for a CPP file using a custom style sheet
        __APP__ sample.cpp sample.html --css manual.css

        # extract code documentation as simple Markdown
        # ready to be processed further with pandoc
        __APP__ sample.cpp sample.md 

        # convert a Markdown file to HTML
        __APP__ sample.md sample.html
        
        # convert a Markdown file to HTML with own css, header and foot
        __APP__ sample.md sample.html --css my.css --footer foot.html --header head.html
        
        # convert a Markdown file to HTML parsing embedded Latex Formula
        # using \\( inline formula \\) or \\[ block formula syntax \\]
        
        __APP__ sample.md sample.html --javascript highlightjs
        
        # convert a Markdown file to HTML parsing embedded Latex Formula
        # using \\( inline formula \\) or \\[ block formula syntax \\]
        
        __APP__ sample.md sample.html --mathjax true 
        
    Author: @ Detlef Groth, University of Potsdam, Germany 2019-2025

    License: BSD
}]

    
    if {[lsearch -exact $argv {--version}] > -1} {
        puts "[package provide mndoc]"
    } elseif {[lsearch -exact $argv {--license}] > -1} {
        puts "BSD License - see manual page"
    } elseif {[lsearch -exact $argv {--help}] > -1} {
        set usage [regsub -all {__VERSION__} [regsub -all {__APP__} $USAGE $APP] [package provide mndoc]]
        puts $usage
        set help [regsub -all {__VERSION__} [regsub -all {__APP__} $HELP $APP] [package provide mndoc]]
        puts $help
        exit 0
    } elseif {[llength $argv] < 2} {
        set usage [regsub -all {__VERSION__} [regsub -all {__APP__} $USAGE $APP] [package provide mndoc]]
        puts $usage
    } elseif {[llength $argv] == 2} {
        if {[regexp {^-.} [lindex $argv 1]]} {
            puts stderr "Error: wrong outfile name [lindex $argv 1]"
            exit 1
        }
        mndoc::mndoc [lindex $argv 0] [lindex $argv 1]
    
    } elseif {[llength $argv] > 2} {
        foreach arg $argv {
            if {[regexp {^-.+} $arg]} {
                if {$arg ni $valid_args} {
                    puts "Error: The argument '$arg' is not valid!"
                    set usage [regsub -all {__VERSION__} [regsub -all {__APP__} $USAGE $APP] [package provide mndoc]]
                    puts $usage
                    exit 0
                }
                    
            }
        }
        if {! [expr {[llength $argv] % 2 == 0}]} {
            puts "Error: option List must have an even length of type '--option value'!"
            set usage [regsub -all {__VERSION__} [regsub -all {__APP__} $USAGE $APP] [package provide mndoc]]
            puts $usage
            exit 0
        }
        mndoc::mndoc {*}$argv
    }
}
#'
#' ## <a name='format'>FORMATTING</a>
#' 
#' For a complete list of Markdown formatting commands consult the basic Markdown syntax at [https://daringfireball.net](https://daringfireball.net/projects/markdown/syntax). 
#' Here just the most basic essentials  to create documentation are described.
#' Please note, that formatting blocks in Markdown are separated by an empty line, and empty line in this documenting mode is a line prefixed with the `#'` and nothing thereafter. 
#'
#' **Title, Author and Date**
#' 
#' Title, author and date can be set at the beginning of the documentation in a so called YAML header. 
#' This header will be as well used by the document converter [pandoc](https://pandoc.org)  to handle various options for later processing if you extract not HTML but Markdown code from your documentation.
#'
#' A YAML header starts and ends with three hyphens. Here is the YAML header of this document:
#' 
#' ```
#' #' ---
#' #' title: mndoc - Markdown extractor and formatter
#' #' author: Dr. Detlef Groth, Schwielowsee, Germany
#' #' date: 2025-01-04
#' #' ---
#' ```
#' 
#' Those five lines produce the three lines on top of this document. You can extend the header if you would like to process your document after extracting the Markdown with other tools, for instance with Pandoc.
#' 
#' You can as well specify an other style sheet, than the default by adding
#' the following style information:
#'
#' ```
#' #' ---
#' #' title: mndoc - Markdown extractor and formatter
#' #' author: Dr. Detlef Groth, Schwielowsee, Germany
#' #' date: 2024-11-21
#' #' css: tufte.css
#' #' ---
#' ```
#' 
#' Please note, that the indentation is required and it is two spaces.
#'
#' **Headers**
#'
#' Headers are prefixed with the hash symbol, single hash stands for level 1 heading, double hashes for level 2 heading, etc.
#' Please note, that the embedded style sheet centers level 1 and level 3 headers, there are intended to be used
#' for the page title (h1), author (h3) and date information (h3) on top of the page.
#' 
#' ```
#'   #'  ## <a name="sectionname">Section title</a>
#'   #'    
#'   #'  Some free text that follows after the required empty 
#'   #'  line above ...
#' ```
#'
#' This produces a level 2 header. Please note, if you have a section name `synopsis` the code fragments thereafer will be hilighted different than the other code fragments. You should only use level 2 and 3 headers for the documentation. Level 1 header are reserved for the title.
#' 
#' **Lists**
#'
#' Lists can be given either using hyphens or stars at the beginning of a line.
#'
#' ```
#' #' - item 1
#' #' - item 2
#' #' - item 3
#' ```
#' 
#' Here the output:
#'
#' - item 1
#' - item 2
#' - item 3
#' 
#' A special list on top of the help page could be the table of contents list. Here is an example:
#'
#' ```
#' #' ## Table of Contents
#' #'
#' #' - [Synopsis](#synopsis)
#' #' - [Description](#description)
#' #' - [Command](#command)
#' #' - [Example](#example)
#' #' - [Authors](#author)
#' ```
#'
#' This will produce in HTML mode a clickable hyperlink list. You should however create
#' the name targets using html code like so:
#'
#'
#'      <a name='synopsis'>Synopsis2</a> 
#'
#'
#' **Hyperlinks**
#'
#' Hyperlinks are written with the following markup code:
#'
#' ```
#' [Link text](URL)
#' ```
#' 
#' Let's link to the Tcler's Wiki:
#' 
#' ```
#' [Tcler's Wiki](https://wiki.tcl-lang.org/)
#' ```
#' 
#' produces: [Tcler's Wiki](https://wiki.tcl-lang.org/)
#'
#' **Indentations**
#'
#' Indentations are achieved using the greater sign:
#' 
#' ```
#' #' Some text before
#' #'
#' #' > this will be indented
#' #'
#' #' This will be not indented again
#' ```
#' 
#' Here the output:
#'
#' Some text before
#' 
#' > this will be indented
#' 
#' This will be not indented again
#'
#' Also lists can be indented:
#' 
#' ```
#' > - item 1
#'   - item 2
#'   - item 3
#' ```
#'
#' produces:
#'
#' > - item 1
#'   - item 2
#'   - item 3
#'
#' **Fontfaces**
#' 
#' Italic font face can be requested by using single stars or underlines at the beginning 
#' and at the end of the text. Bold is achieved by dublicating those symbols:
#' Monospace font appears within backticks.
#' Here an example:
#' 
#' ```
#' #' > I am _italic_ and I am __bold__! But I am programming code: `ls -l`
#' ```
#'
#' > I am _italic_ and I am __bold__! But I am programming code: `ls -l`
#' 
#' **Images**
#'
#' If you insist on images in your documentation, images can be embedded in Markdown with a syntax close to links.
#' The links here however start with an exclamation mark:
#' 
#' ```
#' #' ![image caption](filename.png)
#' ```
#' 
#' The source code of mndoc.tcl is a good example for usage of this source code 
#' annotation tool. Don't overuse the possibilities of Markdown, sometimes less is more. 
#' Write clear and concise, don't use fancy visual effects.
#' 
#' ### <a name="code-blocks">Code blocks</a>
#'
#' Code blocks can be started using either three or more spaces after the #' sequence 
#' or by embracing the code block with triple backticks on top and on bottom. Here an example:
#' 
#' ```
#' #' ```
#' #' puts "Hello World!"
#' #' ```
#' ```
#'
#' Here the output:
#'
#' ```
#' puts "Hello World!"
#' ```
#'
#' Since version 0.8.0 mndoc as well included the inclusion of Javascript files or libraries like the library 
#' [highlighjs](https://highlightjs.org/). Just use the command line or mndoc function argument `--javascript highlightjs`
#' and you get syntax highlighting for code blocks. Here an example:
#' 
#' ```
#' #' ```{r} 
#' #' test <- function () {
#' #'   print("testig2")
#' #' test();
#' #' ```
#' ```
#'
#' Output:
#' 
#' ```{r} 
#' test <- function () {
#'   print("testig2")
#' test();
#' ```
#' 
#' ### <a name="equations">Equations</a>
#'
#' Since version 0.9.0 as well LaTeX equations can be embedded into Markdown documents and are
#' rendered using the [MathJax](https://www.mathjax.org/) library. Just include either inline 
#' equations using parenthesis protected by two backslashes or block equations embedded within
#' brackets protected by two backslashes or within two dollar symbols in your Markdown code and use
#' the option `--mathjax true` during document conversion. Here an example for 
#' inline equations:
#'
#' ```
#' The  famous  Einstein  equation  \\( E = mc^2 \\) is  probably  the most known
#' equation world wide.
#' ```
#' 
#' And here the output (will not work on http://htmlpreview.github.io/):
#' 
#' The  famous  Einstein  equation  \\( E = mc^2 \\) is  probably  the most know
#' equation world wide. 
#' 
#' Block equations should be usually aligned left, like in the
#' following examples:
#'
#' ```
#' <div style="display: flex;">
#' 
#' $$ \sum_{i=0}^n i^2 = \frac{(n^2+n)(2n+1)}{6} \tag{1} $$
#' 
#' </div>
#' ```
#'
#' And here the output:
#' 
#' <div style="display: flex;">
#'
#' $$ \sum_{i=0}^n i^2 = \frac{(n^2+n)(2n+1)}{6} \tag{1} $$
#'
#' </div>
#'
#'
#' **Includes**
#' 
#' mndoc in contrast to standard markdown as well support includes. Using the `#' #include "filename.md"` syntax 
#' it is possible to include other markdown files. This might be useful for instance to include the same 
#' header or a footer in a set of related files.
#'
#' ## <a name='install'>INSTALLATION</a>
#' 
#' The mndoc::mndoc package can be installed either as command line application or as a Tcl module. 
#' It requires the markdown, cmdline, yaml and textutils packages from tcllib to be installed.
#' 
#' Installation as command line application is easiest by downloading the file 
#' [mndoc-0.1X.X.bin](https://github.com/mittelmark/mndoc/releases) from the latest release, which
#' contains the main script file and all required libraries, to your local machine. The X stands for the current release number. 
#' Rename this file to mndoc, make it executable and coy it to a folder belonging to your PATH variable.
#' 
#' Installation as command line application can be as well done by copying the `mndoc.tcl` as 
#' `mndoc` to a directory which is in your executable path. You should make this file executable using `chmod`. 
#' 
#' Installation as Tcl package by copying the mndoc folder to a folder 
#' which is in your library path for Tcl. Alternatively you can install it as Tcl modul by copying it 
#' in your module path as `mndoc-0.1X.X.tm` for instance. See the [tm manual page](https://www.tcl.tk/man/tcl8.6/TclCmd/tm.htm)
#'
#' ## <a name='see'>SEE ALSO</a>
#' 
#' - [tcllib](https://core.tcl-lang.org/tcllib/doc/trunk/embedded/index.md) for the original mkdoc package and the 
#'   Markdown as well as the textutil packages
#' - [pandoc](https://pandoc.org) - am universal document converter
#' - [Ruff!](https://github.com/apnadkarni/ruff) Ruff! documentation generator for Tcl using Markdown syntax as well
#' 
#' ## <a name='changes'>CHANGES</a>
#'
#' - 2019-11-19 Release 0.1
#' - 2019-11-22 Adding direct conversion from Markdown files to HTML files.
#' - 2019-11-27 Documentation fixes
#' - 2019-11-28 Kit version
#' - 2019-11-28 Release 0.2 to fossil
#' - 2019-12-06 Partial R-Roxygen/Markdown support
#' - 2020-01-05 Documentation fixes and version information
#' - 2020-02-02 Adding include syntax
#' - 2020-02-26 Adding stylesheet option --css 
#' - 2020-02-26 Adding files pandoc.css and dgw.css
#' - 2020-02-26 Making standalone file using pkgDeps and mk_tm
#' - 2020-02-26 Release 0.3 to fossil
#' - 2020-02-27 support for \_\_DATE\_\_, \_\_PKGNAME\_\_, \_\_PKGVERSION\_\_ macros  in Tcl code based on package provide line
#' - 2020-09-01 Roxygen2 plugin
#' - 2020-11-09 argument --run supprt
#' - 2020-11-10 Release 0.4
#' - 2020-11-11 command line option  --run with seconds
#' - 2020-12-30 Release 0.5 (rox2md @section support with preformatted, emph and strong/bold)
#' - 2022-02-11 Release 0.6.0 
#'      - parsing yaml header
#'      - workaround for images
#'      - making standalone using tpack.tcl [mndoc-0.6.bin](https://github.com/mittelmark/DGTcl/blob/master/bin/mndoc-0.6.bin)
#'      - terminal help update and cleanup
#'      - moved to Github in Wiki
#'      - code cleanup
#' - 2022-04-XX Release 0.7.0
#'      - removing features to simplify the code, so removed plugin support, underline placeholder and sorting facilitites to reduce code size
#'      - creating tcllib compatible manual page
#'      - aku changes and fixes to include mndoc into tcllib's infrastructure
#'      - splitting of command line app to the apps folder
#'      - adding hook package requirement (benefit?)
#'      - changing license to BSD
#' - 2023-09-07 Release 0.7.1 - image tag fix 
#' - 2023-11-17 Release 0.8.0 
#'      - removed hook package, sorry do not understand what it is doing
#'        and what is the benefit and I could not extend my code with this 
#'      - adding --header and --footer options
#'      - adding --javascript option, single oder multiple files
#'      - extending --css option, single or multiple files
#'      - support for syntax highlighting using hilightjs Javascript
#'      - fixing issues with triple backtick codes, by fixing markdown package
#'        (issue is done on tcllib)
#'      - adding example file in examples to show syntax highlighting
#'      - adding Makefile to build standalone application using tpack (80kb)
#' - 2024-11-16 Release 0.9.0
#'      - support for mathjax
#' - 2024-11-28 Release 0.10.0
#'      - support for refresh option to autorefresh a HTML page 
#'      - removed run support, use pantcl instead
#'      - fixing issues with greater, lower and quote signs in code fragments
#'      - removing inlining external javascript files into HTML output
#'      - adding --base64 option to inline local images and css files
#' - 2024-11-28 Release 0.10.1
#'      - minor documentation fix
#' - 2024-12-24 Release 0.10.2
#'      - amp-amp fix for source code blocks
#' - 2025-01-04 Release 0.11.0
#'      - Tcl 9 support
#' - 2025-01-04 Release 0.11.1
#'      - fixing outfile ending with Tmd, Rmd etc seen as HTML files
#' - 2025-01-18 Release 0.11.2
#'      - fixing inline multiple images on the same line
#' - 2025-01-26 Release 0.11.3
#'      - fixing wrong command line argument crash
#'      - fixing uneven length option list
#' - 2025-10-16 Release 0.13.0
#'      - renamed to mndoc with version 0.13.0 to avoid name collisions with
#'        tcllib package
#'
#' ## <a name='todo'>TODO</a>
#'
#' - dtplite support ?
#'
#' ## <a name='authors'>AUTHOR(s)</a>
#'
#' The **mndoc::mndoc** package was written by Dr. Detlef Groth, University of Potdam, Germany.
#'
#' ## <a name='license'>LICENSE AND COPYRIGHT</a>
#'
#' Markdown extractor and converter mndoc::mndoc, version 0.13.0
#'
#' Copyright (c) 2019-25  Detlef Groth, E-mail: <dgroth(at)uni(minus)potsdam(dot)de>
#' 
#' BSD License type:
#'
#' Sun Microsystems, Inc. The following terms apply to all files a ssociated
#' with the software unless explicitly disclaimed in individual files. 
#' 
#' The authors hereby grant permission to use, copy, modify, distribute, and
#' license this software and its documentation for any purpose, provided that
#' existing copyright notices are retained in all copies and that this notice
#' is included verbatim in any distributions. No written agreement, license,
#' or royalty fee is required for any of the authorized uses. Modifications to
#' this software may be copyrighted by their authors and need not follow the
#' licensing terms described here, provided that the new terms are clearly
#' indicated on the first page of each file where they apply. 
#'
#' In no event shall the authors or distributors be liable to any party for
#' direct, indirect, special, incidental, or consequential damages arising out
#' of the use of this software, its documentation, or any derivatives thereof,
#' even if the authors have been advised of the possibility of such damage. 
#'
#' The authors and distributors specifically disclaim any warranties,
#' including, but not limited to, the implied warranties of merchantability,
#' fitness for a particular purpose, and non-infringement. This software is
#' provided on an "as is" basis, and the authors and distributors have no
#' obligation to provide maintenance, support, updates, enhancements, or
#' modifications. 
#'
#' RESTRICTED RIGHTS: Use, duplication or disclosure by the government is
#' subject to the restrictions as set forth in subparagraph (c) (1) (ii) of
#' the Rights in Technical Data and Computer Software Clause as DFARS
#' 252.227-7013 and FAR 52.227-19. 
#'

