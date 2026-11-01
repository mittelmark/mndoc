## Build a standalone command line application 
## mndoc

yaml-files=pkgIndex.tcl huddle.tcl huddle_types.tcl json2huddle.tcl yaml.tcl
cmdl-files=pkgIndex.tcl cmdline.tcl
mdown-files=markdown.tcl pkgIndex.tcl
txutl-files=tabify.tcl repeat.tcl pkgIndex.tcl
tcllib-commit=a0f8da869ea3f8dc0dee583d18316edc435dbc64
tcllib=https://raw.githubusercontent.com/tcltk/tcllib/$(tcllib-commit)/
VERSION=$(shell grep "package ifneeded" mndoc/pkgIndex.tcl | grep -Eo '[.0-9]{2,}' | head -1)
TCL9=~/.local/opt/bin/tclsh9.0
TCL=tclsh
app:	bin/tpack
	-rm -rf mndoc.vfs
	./bin/tpack init mndoc.vfs
	rm -rf mndoc.vfs/lib/test
	cp apps/mndoc mndoc.tcl
	mkdir mndoc.vfs/lib/mndoc
	cp mndoc/mndoc.tcl mndoc.vfs/lib/mndoc/
	cp mndoc/pkgIndex.tcl mndoc.vfs/lib/mndoc/
	cp mndoc/mndoc.css mndoc.vfs/lib/mndoc/
	cp mndoc/tmdoc.css mndoc.vfs/lib/mndoc/
	cp mndoc/book.css mndoc.vfs/lib/mndoc/
	mkdir mndoc.vfs/lib/cmdline
	mkdir mndoc.vfs/lib/markdown
	mkdir mndoc.vfs/lib/textutil
	mkdir mndoc.vfs/lib/yaml	
	for file in $(cmdl-files); do wget $(tcllib)modules/cmdline/$${file} -O mndoc.vfs/lib/cmdline/$${file}; done	
	for file in $(yaml-files); do wget $(tcllib)modules/yaml/$${file} -O mndoc.vfs/lib/yaml/$${file}; done	
	for file in $(mdown-files); do wget $(tcllib)modules/markdown/$${file} -O mndoc.vfs/lib/markdown/$${file}; done
	@if grep -qF '{(?:^\s{0,3}|[^\\`]+)\|(?:[^`])}' mndoc.vfs/lib/markdown/markdown.tcl; then \
		echo "markdown pipe fix already present"; \
	else \
		cd mndoc.vfs/lib/markdown && patch markdown.tcl -i ../../../patches/markdown.patch; \
	fi
	## fix bug for code in triple backtick section
	perl -pe 's/set code_result \[html_escape +.code_result\]//' mndoc.vfs/lib/markdown/markdown.tcl > temp.tcl
	perl -i -pe 's/1\.2\.4/1.2.5/' temp.tcl
	perl -i -pe 's/1\.2\.4/1.2.5/' mndoc.vfs/lib/markdown/pkgIndex.tcl
	mv temp.tcl mndoc.vfs/lib/markdown/markdown.tcl
	for file in $(txutl-files); do wget $(tcllib)modules/textutil/$${file} -O mndoc.vfs/lib/textutil/$${file}; done	
	$(TCL) ./bin/tpack wrap mndoc.tapp --lz4
	[ -d bin ] || mkdir bin
	cp mndoc.tapp bin/mndoc-`tclsh mndoc.tapp --version`.bin
	ls -lth bin/mndoc*.bin
	echo done

test-hightlight:
	 tclsh ./bin/mndoc-$(VERSION).bin examples/hilight.md examples/hilight.html --javascript highlightjs
test-equations:
	tclsh ./bin/mndoc-$(VERSION).bin examples/equations.md examples/equations.html --mathjax true
test-inline:
	tclsh ./bin/mndoc-$(VERSION).bin examples/extern.html examples/intern.html 
test-header:
	tclsh ./bin/mndoc-$(VERSION).bin examples/header.md examples/header.html --bodyonly true
test-image:
	tclsh ./bin/mndoc-$(VERSION).bin examples/image.md examples/image.html
## PDF paper size from the locale: LC_PAPER (which falls back to LANG)
## reports width=216 for US Letter locales like en_US and width=210 for
## A4 locales like de_DE and for the C locale. Override e.g. with:
## make docu PAPER=Letter
PAPER?=$(shell locale -k LC_PAPER 2>/dev/null | sed -n 's/^width=//p' | grep -qE '^215.9$$|^216$$' && echo Letter || echo A4)
## neither WeasyPrint 70 nor headless Chromium has a paper size command
## line flag, so the size is injected as CSS into a throwaway copy of the
## generated HTML, which is removed again after the PDF was written
PAPERCSS=<style>@page { size: $(PAPER); }</style>

docu:
	TCLLIBPATH=`pwd`/mndoc.vfs/lib tclsh apps/mndoc mndoc/mndoc.tcl mndoc/mndoc.html --css mndoc.css --mathjax true --javascript highlightjs
	#htmlark --ignore-js mndoc/mndoc.html -o mndoc/mndoc-out.html
	sed 's|</head>|$(PAPERCSS)</head>|' mndoc/mndoc.html > mndoc/.print.html
	cd mndoc && weasyprint .print.html mndoc.pdf
	rm -f mndoc/.print.html
	#cp mndoc/mndoc-out.html mndoc/mndoc.html
# render the manual itself with the book stylesheet, as a showcase for book.css
docu-book:
	TCLLIBPATH=`pwd`/mndoc.vfs/lib tclsh apps/mndoc mndoc/mndoc.tcl examples/manual-book.html --css book.css --mathjax true --javascript highlightjs
	sed 's|</head>|$(PAPERCSS)</head>|' examples/manual-book.html > examples/.print.html
	cd examples && weasyprint .print.html manual-book.pdf
	rm -f examples/.print.html
## headless Chromium variants of the two PDF steps above: WeasyPrint cannot
## run JavaScript, so equations rendered by MathJax (and code highlighted by
## highlight.js) only appear in the PDF when a browser does the HTML to PDF
## step. CHROME can be overridden, e.g. CHROME=google-chrome.
CHROME?=chromium-browser
CHROMEFLAGS=--headless=new --disable-gpu --no-pdf-header-footer --virtual-time-budget=15000

docu-browser:
	TCLLIBPATH=`pwd`/mndoc.vfs/lib tclsh apps/mndoc mndoc/mndoc.tcl mndoc/mndoc.html --css mndoc.css --mathjax true --javascript highlightjs
	sed 's|</head>|$(PAPERCSS)</head>|' mndoc/mndoc.html > mndoc/.print.html
	$(CHROME) $(CHROMEFLAGS) --print-to-pdf=mndoc/mndoc.pdf file://`pwd`/mndoc/.print.html
	rm -f mndoc/.print.html

docu-book-browser:
	TCLLIBPATH=`pwd`/mndoc.vfs/lib tclsh apps/mndoc mndoc/mndoc.tcl examples/manual-book.html --css book.css --mathjax true --javascript highlightjs
	sed 's|</head>|$(PAPERCSS)</head>|' examples/manual-book.html > examples/.print.html
	$(CHROME) $(CHROMEFLAGS) --print-to-pdf=examples/manual-book.pdf file://`pwd`/examples/.print.html
	rm -f examples/.print.html
test:
	@echo "Running tests..."
	@set -e; \
	tmp=`mktemp -d`; \
	trap 'rm -rf "$$tmp"' EXIT; \
	export TCLLIBPATH="$(CURDIR)/mndoc.vfs/lib"; \
	test -d "$$TCLLIBPATH" || { echo "Error: mndoc.vfs is missing, run 'make app' first"; exit 1; }; \
	tclsh apps/mndoc examples/hilight.md "$$tmp/hilight.html" --javascript highlightjs; \
	grep -q "highlight.min.js" "$$tmp/hilight.html"; \
	echo "  ... highlight passing"; \
	tclsh apps/mndoc examples/hilight.md "$$tmp/refresh.html" --refresh 10; \
	grep -qE 'http-equiv="refresh" content="10"' "$$tmp/refresh.html"; \
	echo "  ... refresh passing"; \
	tclsh apps/mndoc examples/extern.html "$$tmp/intern.html"; \
	grep -q 'data:image/png;base64' "$$tmp/intern.html"; \
	echo "  ... base64 html input passing"; \
	tclsh apps/mndoc examples/extern.html "$$tmp/intern-plain.html" --base64 false; \
	! grep -q 'data:image/png;base64' "$$tmp/intern-plain.html"; \
	grep -q 'src="dot.png"' "$$tmp/intern-plain.html"; \
	echo "  ... base64 disabled passing"; \
	tclsh apps/mndoc examples/image.md "$$tmp/image.html" --base64 false; \
	! grep -q 'data:image/png;base64' "$$tmp/image.html"; \
	echo "  ... base64 markdown passing"; \
	printf '%s\n' '---' 'title: T' '---' '' \
	  '![a](dot.png){width="800"}' '' \
	  '![b](dot.png){width="150px"}' '' \
	  '![c](dot.png){width="600" height="400"}' '' \
	  '![d](dot.png){height="200"}' '' \
	  '![e](dot.png){width="50%"}' '' > "$$tmp/size.md"; \
	cp examples/dot.png "$$tmp/dot.png"; \
	tclsh apps/mndoc "$$tmp/size.md" "$$tmp/size.html"; \
	grep -q 'alt="a" width="800" style="width:800px"' "$$tmp/size.html"; \
	grep -q 'alt="b" width="150" style="width:150px"' "$$tmp/size.html"; \
	! grep -q 'width="150px"' "$$tmp/size.html"; \
	grep -q 'alt="c" width="600" height="400" style="width:600px;height:400px"' "$$tmp/size.html"; \
	grep -q 'alt="d" height="200" style="height:200px"' "$$tmp/size.html"; \
	grep -qE 'alt="e"[[:space:]]+style="width:50%"' "$$tmp/size.html"; \
	! grep -q 'width="50%"' "$$tmp/size.html"; \
	echo "  ... image width translation passing"; \
	grep -q 'max-width: 1000px' "$$tmp/size.html"; \
	! grep -q 'max-width: 800px' "$$tmp/size.html"; \
	echo "  ... 1000px measure passing"; \
	printf '%s\n' '---' 'title: T' '---' '' \
	  'prose with an inline ![i](dot.png) mark' '' \
	  '![f](dot.png)' '' \
	  'lazy text' '![l](dot.png)' '' \
	  '- ![b](dot.png)' '' > "$$tmp/fig.md"; \
	cp examples/dot.png "$$tmp/dot.png"; \
	tclsh apps/mndoc "$$tmp/fig.md" "$$tmp/fig.html" --base64 false; \
	grep -qE 'alt="f" data-figure' "$$tmp/fig.html"; \
	grep -qE 'alt="b" data-figure' "$$tmp/fig.html"; \
	! grep -qE 'alt="i" data-figure' "$$tmp/fig.html"; \
	! grep -qE 'alt="l" data-figure' "$$tmp/fig.html"; \
	tclsh apps/mndoc examples/extern.html "$$tmp/fig-html.html"; \
	grep -qE 'data-figure ?/?>' "$$tmp/fig-html.html"; \
	tclsh apps/mndoc examples/extern.html "$$tmp/fig-html-plain.html" --base64 false; \
	grep -qE 'data-figure ?/?>' "$$tmp/fig-html-plain.html"; \
	echo "  ... figure marking passing"; \
	printf '%s\n' '---' 'title: test-title' 'author: NN' 'date: 2024-11-20' '---' '' 'hello' '' > "$$tmp/test.md"; \
	tclsh apps/mndoc "$$tmp/test.md" "$$tmp/test.html"; \
	grep -q '<h1 class="title">test-title</h1>' "$$tmp/test.html"; \
	grep -q '<h2 class="date">2024-11-20</h2>' "$$tmp/test.html"; \
	grep -q '<h2 class="author">NN</h2>' "$$tmp/test.html"; \
	grep -q '<p>hello</p>' "$$tmp/test.html"; \
	echo "  ... yaml title/author/date passing"; \
	printf '%s\n' '---' 'title: T' 'author: A' 'date: "28.10.2026"' '---' '' 'text' '' > "$$tmp/date-de.md"; \
	tclsh apps/mndoc "$$tmp/date-de.md" "$$tmp/date-de.html"; \
	grep -q '<h2 class="date">28.10.2026</h2>' "$$tmp/date-de.html"; \
	echo "  ... non-ISO date passing"; \
	printf '%s\n' '---' 'title: T' 'author: A' 'date: 2026' '---' '' 'text' '' > "$$tmp/date-year.md"; \
	tclsh apps/mndoc "$$tmp/date-year.md" "$$tmp/date-year.html"; \
	grep -q '<h2 class="date">2026</h2>' "$$tmp/date-year.html"; \
	echo "  ... integer date fallback passing"; \
	tclsh apps/mndoc tests/tables.md "$$tmp/tables.html"; \
	grep -q '<table class="table">' "$$tmp/tables.html"; \
	grep -q 'two pipes like this <code>||</code>' "$$tmp/tables.html"; \
	echo "  ... tables passing"; \
	mkdir -p "$$tmp/docs/css"; \
	printf '%s\n' '# T' '' 'text' '' > "$$tmp/docs/in.md"; \
	printf '%s\n' 'body { color: red; }' > "$$tmp/docs/css/style.css"; \
	tclsh apps/mndoc "$$tmp/docs/in.md" "$$tmp/docs/out.html" --css css/style.css; \
	! grep -q '<link rel="stylesheet" href="css/style.css">' "$$tmp/docs/out.html"; \
	grep -q 'data:text/css;base64' "$$tmp/docs/out.html"; \
	echo "  ... nested css inlining passing"; \
	printf '%s\n' '# T' '' 'text' '' > "$$tmp/docs/in2.md"; \
	rm -f tmdoc.css; \
	tclsh apps/mndoc "$$tmp/docs/in2.md" "$$tmp/docs/out2.html" --css tmdoc.css; \
	grep -q 'data:text/css;base64' "$$tmp/docs/out2.html"; \
	! grep -q 'href="tmdoc.css"' "$$tmp/docs/out2.html"; \
	! test -e tmdoc.css; \
	echo "  ... document-relative css fallback passing"; \
	printf '%s\n' '---' 'title: T' '---' '' 'Grüße — mit UTF-8' '' > "$$tmp/utf8.md"; \
	tclsh apps/mndoc "$$tmp/utf8.md" "$$tmp/utf8.html"; \
	grep -q '<meta charset="utf-8">' "$$tmp/utf8.html"; \
	grep -q 'Grüße — mit UTF-8' "$$tmp/utf8.html"; \
	echo "  ... utf8 charset passing"; \
	tclsh apps/mndoc "$$tmp/test.md" "$$tmp/bodyonly.html" --bodyonly true; \
	! grep -q '<!DOCTYPE html>' "$$tmp/bodyonly.html"; \
	grep -q '<p>hello</p>' "$$tmp/bodyonly.html"; \
	echo "  ... bodyonly passing"; \
	tclsh apps/mndoc --bodyonly true "$$tmp/test.md" "$$tmp/opts-first.html"; \
	! grep -q '<!DOCTYPE html>' "$$tmp/opts-first.html"; \
	grep -q '<p>hello</p>' "$$tmp/opts-first.html"; \
	tclsh apps/mndoc "$$tmp/test.md" --refresh 10 "$$tmp/opts-mixed.html"; \
	grep -qE 'http-equiv="refresh" content="10"' "$$tmp/opts-mixed.html"; \
	echo "  ... option order passing"; \
	echo "Tests passed successfully!"
run:
	@TCLLIBPATH=`pwd` tclsh apps/mndoc mndoc.tcl --run

bin/tpack: patches/tpack-race.patch
	wget https://github.com/mittelmark/tpack/releases/download/v0.7.1/tpack -O bin/tpack
	chmod 755 bin/tpack
	patch -p1 -i patches/tpack-race.patch
