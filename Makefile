## Build a standalone command line application 
## mndoc

yaml-files=pkgIndex.tcl huddle.tcl huddle_types.tcl json2huddle.tcl yaml.tcl
cmdl-files=pkgIndex.tcl cmdline.tcl
mdown-files=markdown.tcl pkgIndex.tcl
txutl-files=tabify.tcl repeat.tcl pkgIndex.tcl
tcllib=https://raw.githubusercontent.com/tcltk/tcllib/master/
VERSION=$(shell grep "package ifneeded" mndoc/pkgIndex.tcl | grep -Eo '[.0-9]{2,}')
TCL9=~/.local/opt/bin/tclsh9.0
TCL=tclsh
app:	
	-rm -rf mndoc.vfs
	tpack init mndoc.vfs
	rm -rf mndoc.vfs/lib/test
	cp apps/mndoc mndoc.tcl
	mkdir mndoc.vfs/lib/mndoc
	cp mndoc/mndoc.tcl mndoc.vfs/lib/mndoc/
	cp mndoc/pkgIndex.tcl mndoc.vfs/lib/mndoc/
	mkdir mndoc.vfs/lib/cmdline
	mkdir mndoc.vfs/lib/markdown
	mkdir mndoc.vfs/lib/textutil
	mkdir mndoc.vfs/lib/yaml	
	for file in $(cmdl-files); do wget $(tcllib)modules/cmdline/$${file} -O mndoc.vfs/lib/cmdline/$${file}; done	
	for file in $(yaml-files); do wget $(tcllib)modules/yaml/$${file} -O mndoc.vfs/lib/yaml/$${file}; done	
	for file in $(mdown-files); do wget $(tcllib)modules/markdown/$${file} -O mndoc.vfs/lib/markdown/$${file}; done
	## fix bug for code in triple backtick section
	perl -pe 's/set code_result \[html_escape +.code_result\]//' mndoc.vfs/lib/markdown/markdown.tcl > temp.tcl
	mv temp.tcl mndoc.vfs/lib/markdown/markdown.tcl
	for file in $(txutl-files); do wget $(tcllib)modules/textutil/$${file} -O mndoc.vfs/lib/textutil/$${file}; done	
	$(TCL) ../tpack/tpack-b64.tcl wrap mndoc.tapp --lz4
	[ -d bin ] || mkdir bin
	cp mndoc.tapp bin/mndoc-`tclsh mndoc.tapp --version`.bin
	ls -lth bin/mndoc*.bin
	echo done

test-hightlight:
	 tclsh ./bin/mndoc-$(VERSION).bin examples/test.md examples/test.html --javascript highlightjs
test-equations:
	echo $(VERSION)
	tclsh ./bin/mndoc-$(VERSION).bin examples/equations.md examples/equations.html --mathjax true
	echo done
docu:
	TCLLIBPATH=`pwd`/mndoc.vfs/lib tclsh apps/mndoc mndoc/mndoc.tcl mndoc/mndoc.html --css mndoc.css --mathjax true --javascript highlightjs
	#htmlark --ignore-js mndoc/mndoc.html -o mndoc/mndoc-out.html
	#cp mndoc/mndoc-out.html mndoc/mndoc.html
tests:
	@echo "Running tests..."
	@TCLLIBPATH=`pwd` tclsh apps/mndoc examples/hilight.md examples/hilight.html --javascript highlightjs && grep -q "highlight.min.js" examples/hilight.html || (echo "Error: Expected highlightjs output not found"; exit 1) && echo "  ... highlight passing"
	@TCLLIBPATH=`pwd` tclsh apps/mndoc examples/hilight.md examples/hilight-refresh.html --refresh 10 && grep -qE "http-equiv=.refresh.+10" examples/hilight-refresh.html || (echo "Error: Expected refresh output not found"; exit 1) && echo "  ... refresh passing"	
	@echo -e "---\ntitle: test-title\nauthor: NN\ndate: 2024-11-20\n---\n\nhello\n\n" > test.md
	@TCLLIBPATH=`pwd` tclsh apps/mndoc test.md test.html
	@grep -qE "<h1 class=\"title\">test-title</h1>" test.html || (echo "Error: Expected title output not found"; exit 1) && echo "  ... title passing"
	@grep -qE "<h2 class=\"date\">2024-11-20</h2>" test.html || (echo "Error: Expected date output not found"; exit 1) && echo "  ... date passing"
	@grep -qE "<h2 class=\"author\">NN</h2>" test.html || (echo "Error: Expected author output not found"; exit 1) && echo "  ... author passing"
	@grep -qE "<p>hello</p>" test.html || (echo "Error: Expected paragraph output not found"; exit 1) && echo "  ... paragraph passing"
	@cp test.html hello.html
	@cp test.md hello.md
	@echo "## header" > test.md
	@TCLLIBPATH=`pwd` tclsh apps/mndoc test.md test.html && grep -qE "<h2>header</h2>" test.html || (echo "Error: Expected header output not found"; exit 1) && echo "  ... header passing"
	@echo "Tests passed successfully!"
run:
	@TCLLIBPATH=`pwd` tclsh apps/mndoc mndoc.tcl --run
