all:
	JUPYTER_BOOK_BUILD=true jupyter-book build . -v
pdf:
	JUPYTER_BOOK_BUILD=true jupyter-book build . --builder pdfhtml -v

pdfl:
	JUPYTER_BOOK_BUILD=true jupyter-book build . --builder pdflatex -v
	pdftk CIMR_DEVALGO_WP1_SeaIceThicknessATBD_D4_v2_frontpage.pdf _build/latex/atbd.pdf cat output CIMR_DEVALGO_WP1_SeaIceThicknessATBD_D4_v2.pdf

clean:
	jupyter-book clean .

purge:
	rm -rf ./_build
