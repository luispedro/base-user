mkdir -p .tex_files
cd .tex_files
TEXINPUTS=..:../cmu-beamer/:.:../images/:../figures/: pdflatex presentation
cp presentation.pdf ..
