all: ytd ytdm.bash-completion ytdm.zsh ytdm.fish supportedsites

clean:
	rm -rf ytdm.1.temp.md ytdm.1 ytdm.bash-completion README.txt MANIFEST build/ dist/ .coverage cover/ ytdm.tar.gz ytdm.zsh ytdm.fish ytdm/extractor/lazy_extractors.py *.dump *.part* *.ytdl *.info.json *.mp4 *.m4a *.flv *.mp3 *.avi *.mkv *.webm *.3gp *.wav *.ape *.swf *.jpg *.png ytd
	find . -name "*.pyc" -delete
	find . -name "*.class" -delete

PREFIX ?= /usr/local
BINDIR ?= $(PREFIX)/bin
MANDIR ?= $(PREFIX)/man
SHAREDIR ?= $(PREFIX)/share
PYTHON ?= /usr/bin/env python

# set SYSCONFDIR to /etc if PREFIX=/usr or PREFIX=/usr/local
SYSCONFDIR = $(shell if [ $(PREFIX) = /usr -o $(PREFIX) = /usr/local ]; then echo /etc; else echo $(PREFIX)/etc; fi)

# set markdown input format to "markdown-smart" for pandoc version 2 and to "markdown" for pandoc prior to version 2
MARKDOWN = $(shell if [ `pandoc -v | head -n1 | cut -d" " -f2 | head -c1` = "2" ]; then echo markdown-smart; else echo markdown; fi)

install: ytdm ytdm.1 ytdm.bash-completion ytdm.zsh ytdm.fish
	install -d $(DESTDIR)$(BINDIR)
	install -m 755 ytdm $(DESTDIR)$(BINDIR)
	install -d $(DESTDIR)$(MANDIR)/man1
	install -m 644 ytdm.1 $(DESTDIR)$(MANDIR)/man1
	install -d $(DESTDIR)$(SYSCONFDIR)/bash_completion.d
	install -m 644 ytdm.bash-completion $(DESTDIR)$(SYSCONFDIR)/bash_completion.d/ytdm
	install -d $(DESTDIR)$(SHAREDIR)/zsh/site-functions
	install -m 644 ytdm.zsh $(DESTDIR)$(SHAREDIR)/zsh/site-functions/_ytdm
	install -d $(DESTDIR)$(SYSCONFDIR)/fish/completions
	install -m 644 ytdm.fish $(DESTDIR)$(SYSCONFDIR)/fish/completions/ytdm.fish

codetest:
	flake8 .

tar: ytdm.tar.gz

.PHONY: all clean install tar bash-completion pypi-files zsh-completion fish-completion codetest supportedsites

pypi-files: ytdm.bash-completion ytdm.1 ytdm.fish

ytd: ytdm/*.py ytdm/*/*.py
	mkdir -p zip
	for d in ytdm ytdm/downloader ytdm/extractor ytdm/postprocessor ; do \
	  mkdir -p zip/$$d ;\
	  cp -pPR $$d/*.py zip/$$d/ ;\
	done
	touch -t 200001010101 zip/ytdm/*.py zip/ytdm/*/*.py
	mv zip/ytdm/__main__.py zip/
	cd zip ; zip -q ../ytd ytdm/*.py ytdm/*/*.py __main__.py
	rm -rf zip
	echo '#!$(PYTHON)' > ytd
	cat ytd.zip >> ytd
	rm ytd.zip
	chmod a+x ytd

supportedsites:
	$(PYTHON) devscripts/make_supportedsites.py docs/supportedsites.md

ytdm.bash-completion: ytdm/*.py ytdm/*/*.py devscripts/bash-completion.in
	$(PYTHON) devscripts/bash-completion.py

bash-completion: ytdm.bash-completion

ytdm.zsh: ytdm/*.py ytdm/*/*.py devscripts/zsh-completion.in
	$(PYTHON) devscripts/zsh-completion.py

zsh-completion: ytdm.zsh

ytdm.fish: ytdm/*.py ytdm/*/*.py devscripts/fish-completion.in
	$(PYTHON) devscripts/fish-completion.py

fish-completion: ytdm.fish

lazy-extractors: ytdm/extractor/lazy_extractors.py

_EXTRACTOR_FILES = $(shell find ytdm/extractor -iname '*.py' -and -not -iname 'lazy_extractors.py')
ytdm/extractor/lazy_extractors.py: devscripts/make_lazy_extractors.py devscripts/lazy_load_template.py $(_EXTRACTOR_FILES)
	$(PYTHON) devscripts/make_lazy_extractors.py $@

ytdm.tar.gz: ytdm README.md README.txt ytdm.1 ytdm.bash-completion ytdm.zsh ytdm.fish ChangeLog AUTHORS
	@tar -czf ytdm.tar.gz --transform "s|^|ytdm/|" --owner 0 --group 0 \
		--exclude '*.DS_Store' \
		--exclude '*.kate-swp' \
		--exclude '*.pyc' \
		--exclude '*.pyo' \
		--exclude '*~' \
		--exclude '__pycache__' \
		--exclude '.git' \
		--exclude 'docs/_build' \
		-- \
		bin devscripts test ytdm docs \
		ChangeLog AUTHORS LICENSE README.md README.txt \
		Makefile MANIFEST.in ytdm.1 ytdm.bash-completion \
		ytdm.zsh ytdm.fish setup.py setup.cfg \
		ytdm
