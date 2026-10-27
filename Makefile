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
docu:
	TCLLIBPATH=`pwd`/mndoc.vfs/lib tclsh apps/mndoc mndoc/mndoc.tcl mndoc/mndoc.html --css mndoc.css --mathjax true --javascript highlightjs
	#htmlark --ignore-js mndoc/mndoc.html -o mndoc/mndoc-out.html
	cd mndoc && weasyprint -s small.css mndoc.html mndoc.pdf 
	#cp mndoc/mndoc-out.html mndoc/mndoc.html
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
	tclsh apps/mndoc "$$tmp/test.md" "$$tmp/bodyonly.html" --bodyonly true; \
	! grep -q '<!DOCTYPE html>' "$$tmp/bodyonly.html"; \
	grep -q '<p>hello</p>' "$$tmp/bodyonly.html"; \
	echo "  ... bodyonly passing"; \
	echo "Tests passed successfully!"
run:
	@TCLLIBPATH=`pwd` tclsh apps/mndoc mndoc.tcl --run

bin/tpack: patches/tpack-race.patch
	wget https://github.com/mittelmark/tpack/releases/download/v0.7.1/tpack -O bin/tpack
	chmod 755 bin/tpack
	patch -p1 -i patches/tpack-race.patch
