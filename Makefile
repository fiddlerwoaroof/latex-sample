preview: combined.png
	"${HOME}"/.iterm2/imgcat combined.png

combined.png: result
	gs -sDEVICE=png16m -o thumb'%02d'.png -r72 result/sample.pdf
	convert -background '#000' +smush 5 thumb*.png combined.png

result: flake.nix flake.lock src/sample.tex
	nix build . --print-build-logs
