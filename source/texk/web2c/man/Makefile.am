## Makefile.am for the TeX Live subdirectory texk/web2c/man/
##
## Copyright (C) 2009, 2010 Peter Breitenlohner <tex-live@tug.org>
## You may freely use, modify and/or distribute this file.
##
man_sources = $(bootstrap_man_sources)
EXTRA_DIST = $(bootstrap_man_sources)
bootstrap_man_sources = ctie.man cweb.man tangle.man tie.man

# Symlinks within $(man1dir): FILE:LINK indicates LINK.1->FILE.1
man1_links = cweb:ctangle cweb:cweave

if WEB
man_sources += $(web_man_sources)
endif WEB
EXTRA_DIST += $(web_man_sources)
web_man_sources = bibtex.man dvicopy.man dvitomp.man dvitype.man gftodvi.man \
	gftopk.man gftype.man mft.man patgen.man pktogf.man pktype.man \
	pltotf.man pooltype.man tftopl.man vftovp.man vptovf.man weave.man

if TEX
man_sources += tex.man
endif TEX
EXTRA_DIST += tex.man

if MF
man_sources += mf.man
if MFN
man1_links += mf:mf-nowin
endif MFN
endif MF
EXTRA_DIST += mf.man

if MP
man_sources += mpost.man
endif MP
EXTRA_DIST += mpost.man

if ETEX
man_sources += etex.man
endif ETEX
EXTRA_DIST += etex.man

if PDFTEX
man_sources += $(pdftex_man_sources)
man1_links += pdftex:pdflatex
endif PDFTEX
EXTRA_DIST += $(pdftex_man_sources)
pdftex_man_sources = pdftex.man pdftosrc.man ttf2afm.man

if LUATEX
man_sources += luatex.man
man1_links += tangle:luatangle
endif LUATEX
EXTRA_DIST += luatex.man

if XETEX
man_sources += # xetex.man
endif XETEX
EXTRA_DIST += # xetex.man

if OTANGLE
man_sources += $(otangle_man_sources)
man1_links += dvicopy:odvicopy dvitype:odvitype tangle:otangle
endif OTANGLE
EXTRA_DIST += $(otangle_man_sources)
otangle_man_sources = ofm2opl.man opl2ofm.man ovf2ovp.man ovp2ovf.man

if ALEPH
man_sources += aleph.man
man1_links += aleph:lambda
endif ALEPH
EXTRA_DIST += aleph.man

man_sources += $(misc_man_sources)
EXTRA_DIST += $(misc_man_sources)
misc_man_sources = \
	amstex.man \
	eplain.man \
	latex.man \
	pdfetex.man

include $(top_srcdir)/../am/man.am

install-data-hook:
	@cd $(DESTDIR)$(man1dir) && \
	  for s in $(man1_links); do \
	    link=`echo $$s | sed 's,.*:,,'`; \
	    file=`echo $$s | sed 's,:.*,,'`; \
	    rm -f $$link.1; \
	    echo "creating link '$$link.1' -> '$$file.1'"; \
	    $(LN_S) $$file.1 $$link.1; \
	  done

uninstall-hook:
	@for s in $(man1_links); do \
	  link=`echo $$s | sed 's,.*:,,'`; \
	  rm -f $(DESTDIR)$(man1dir)/$$link.1; \
	done

## Obsolete ?
##
EXTRA_DIST += \
	amslatex.min \
	initex.min \
	lamstex.min \
	slitex.min \
	spell.add \
	virtex.min

