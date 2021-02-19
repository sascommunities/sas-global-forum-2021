# SASGF LaTeX Submissions

For many, particularly those in academia, their document preperation system of choice is LaTeX. SAS Users have been submitting their papers to local user groups and SAS Global Forum using LaTeX for a long time. However, since 2007 there has been no offical way to template your paper to confirm to the official SAS Global Forum style requirements.

We're really excited that, starting with SAS Global Forum 2021, those presenting at SAS Global Forum 2021 will have the ability to submit their paper as a PDF, conforming to the SAS Global Forum 2021 style requirements, prepared in TeX using thier favorite editor.

Originally authored by [Ronald J. Fehd](https://ctan.org/author/fehd), and published on [CTAN](https://ctan.org/), the Comprehensive TeX Archive Network, the [sugconf](https://ctan.org/pkg/sugconf?lang=en) class allowed users presenters to typeset articles to be published in the SAS Global Forum 2021 proceedings that conform to the standards defined in the SAS Global Forum 2021 [Word Document template](https://github.com/sascommunities/sas-global-forum-2021/tree/main/templates/word).

## Usage

The `SASGF2021-Proceedings-Paper-Template.tex` contains everything that you need to get started with writing your paper. Included in this folder is also an example of the PDF that is generated from this TeX file.

Important files:

* The TeX file - The main event
* `biblio.bib` - The references section of the document is updated from this file. Make sure you update it with your references.
* `*.png` - Images to be included in your paper, at the moment, are just placed in the same directory as the tex file.
* `sugconf.cls` - The class file that does the magical formatting.

Included within this template's folder is a `makefile` which has been tested on Linux but by installing [GNU Make for Windows](http://gnuwin32.sourceforge.net/packages/make.htm) should work on Windows in Powershell too.

To generate a PDF version from your tex file:

```make generate paper=SASGF2021-Proceedings-Paper-Template```

To clean the working directory:

```make clean```

To should the help notes:

```make help```

## Acknowledgements

This template exists thanks to the work originally done by [Ronald Fehd](https://www.linkedin.com/in/ronald-fehd-5125991/). The updates for SAS Global Forum 2021 were done by [Tim Arnold](https://github.com/tiarno).

## About LaTeX

[LaTeX](https://www.latex-project.org/) is a high-quality typesetting system; it includes features designed for the production of technical and scientific documentation. LaTeX is the de facto standard for the communication and publication of scientific documents. 

## About CTAN

The Comprehensive TEX Archive Network (CTAN) is the central place for all kinds of material around TEX. CTAN has currently ~6,000 packages and ~3,000 contributors have contributed to it. Most of the packages are free and can be downloaded and used immediately.