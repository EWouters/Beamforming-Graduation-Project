BUILDDIR = output
TEXDIRS  = conclusion images integration implementation references synchronization test
TEXFILES = $(wildcard *.tex $(patsubst %,%/*,${TEXDIRS}))

AUXFILE = ${BUILDDIR}/thesis.aux
BIBFILE = ${BUILDDIR}/thesis.bbl

all : ${BUILDDIR}/thesis.pdf

clean :
	rm -f ${BUILDDIR}/*

${AUXFILE} : ${TEXFILES}
	pdflatex -output-directory ${BUILDDIR} thesis.tex

${BIBFILE} : ${AUXFILE}
	TEXMFOUTPUT=${BUILDDIR} bibtex ${AUXFILE}

${BUILDDIR}/thesis.pdf : ${TEXFILES} ${AUXFILE} ${BIBFILE}
	pdflatex -output-directory ${BUILDDIR} thesis.tex
	pdflatex -output-directory ${BUILDDIR} thesis.tex

.PHONY  : all clean
.IGNORE : ${BIBFILE}
