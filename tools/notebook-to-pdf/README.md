# SGF Jupyter Notebook to PDF conversion tool

You _can_ export the Jupyter Notebooks to PDF (via LaTex) but when you do that through the notebook the styles are not applied. This tool allows us to apply the SGF paper styling from the `sugconf` latex class (with a couple of modifications for the quirks of Markdown).

This tool is very Alpha.

## Requirements

This application has been built and tested on Fedora 33 but _should_ work on other platforms.

* pandoc 2.9
* python3
* pdflatex
* texlive-scheme-full (I actually don't know if basic/medium/full is required so in an abundance of caution I am stipulating full)

## Usage

From the command line: `python app.py`

| Argument | Description |
| -------- | ----------- |
| `--notebook-dir` or `-d` | The directory which contains the notebook and the supporting files  |
| `--output-dir` or `-o` | The directory where the PDF and Tex (see --include-tex) files should be copied to. |
| `--include-tex` or `-t` | (optional) For debugging, manual adjustment |
| `--markdown-file` or `-m` | (optional) If you already have a markdown file, and you just want to make an SGF PDF. |
| `--bibliography` or `-b` | (optional) If you have a bibliography and you want to include it. |

## TODO
    - [ ] Validate notebook metadata
    - [ ] Workout how to possibly include text/html things from display_data nodes if notebook has been run  
    - [ ] Make this an independent executable so that people can just download and run it if they want to.
    - [X] Map HTML named entities to Latex commands https://tex.stackexchange.com/questions/37126/how-can-i-map-html-named-entities-to-latex-commands
    - [ ] Allow someone to pass their own, or just a different, CSL.