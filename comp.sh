#!/bin/sh

pdflatex theseBD.tex

bibtex theseBD.aux

pdflatex theseBD.tex

pdflatex theseBD.tex
