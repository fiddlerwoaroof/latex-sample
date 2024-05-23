
# Table of Contents



This is a demonstration of using nix to build Latex with minimal dependencies.
Locally, you should be able to run `nix build` and `result/sample.pdf` will be the results of building `src/sample.tex`.
If you'd like to speed up this build, `cachix use latex-sample` should avoid rebuilding the custom texpkgs.

