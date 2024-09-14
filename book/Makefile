env:
	julia -e 'using Pkg; Pkg.activate("../sit_atbd_env_jl"); Pkg.instantiate()'
	
all:
	JUPYTER_BOOK_BUILD=true jupyter-book build . -v

html:
	JUPYTER_BOOK_BUILD=true jupyter-book build . --builder html -v

pdf:
	JUPYTER_BOOK_BUILD=true jupyter-book build . --builder pdfhtml -v

pdfl:
	JUPYTER_BOOK_BUILD=true jupyter-book build . --builder pdflatex -v
	pdftk CIMR_DEVALGO_WP1_SeaIceThicknessATBD_D4_v2_frontpage.pdf _build/latex/atbd.pdf cat output CIMR_DEVALGO_WP1_SeaIceThicknessATBD_D4_v2.pdf

clean:
	jupyter-book clean .

purge:
	rm -rf ./_build
