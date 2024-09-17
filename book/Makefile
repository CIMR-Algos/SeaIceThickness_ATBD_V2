.PHONY: all html pdf pdfl clean purge

fit_params.yml: # executing the notebook to generate model parameters
	jupyter nbconvert --execute --to html cforward_model.ipynb --stdout > /dev/null
# this is also part of the regular build but the order of execution in jupyter book build is not defined, so it had to be executed before the book building

all: fit_params.yml
	JUPYTER_BOOK_BUILD=true jupyter-book build . -v

html: fit_params.yml
	JUPYTER_BOOK_BUILD=true jupyter-book build . --builder html -v

pdf: fit_params.yml
	JUPYTER_BOOK_BUILD=true jupyter-book build . --builder pdfhtml -v

pdfl: fit_params.yml
	JUPYTER_BOOK_BUILD=true jupyter-book build . --builder pdflatex -v
	pdftk CIMR_DEVALGO_WP1_SeaIceThicknessATBD_D4_v2_frontpage.pdf _build/latex/atbd.pdf cat output CIMR_DEVALGO_WP1_SeaIceThicknessATBD_D4_v2.pdf

clean:
	jupyter-book clean .

purge:
	rm -rf ./_build
	rm fit_params.yml
