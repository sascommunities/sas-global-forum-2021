# SASGF Jupyter Notebooks Submissions

While Jupyter Notebooks themselves have been around for a long time and SAS has been supporting them for a number of years, it hasn't been possible to submit your SAS Global Forum paper as a Jupyter Notebook - until now!

We're really excited that, starting with SAS Global Forum 2021, those presenting at SAS Global Forum will have the ability to submit their paper as a Jupyter notebook. The notebook will be hosted as an asset in the SAS Global Forum Proceedings and hosted on Github as an interactive asset that people can engage with.

## Requirements

1. Familiarity with the [SAS kernel](https://github.com/sassoftware/sas_kernel) and [Jupyter notebooks](https://jupyter.org/). See the [SAS with Jupyter](##SAS-with-Jupyter) section for more detail on using SAS with Jupyter.
1. The data publicly available (Kaggle, sashelp, UCI, etc) or you will provide the data along with your paper.
1. The data a reasonable size (not too big)

## How to use this template

This template works in just the same way that the Microsoft Word template, and any other template that you might have used, works. Download it and, following the instructions regarding style contained with, write your paper!

Clone this repository and copy this folder and its contents to the `papers` folder renaming the folder on the way to your paper number, e.g. `1141-2021`. Then, from within the new folder that you just created, write your paper by following the installation and configuration instructions below.

## SAS with Jupyter

Summary:

1. Install Python 3 [(instructions)](https://www.python.org/downloads/)
2. Install Jupyter Notebook [(instructions)](https://jupyter.org/install.html)
3. Start a Python virtual environment `python -m venv env` and activate it `. env/bin/activate`
3. Install the repository's dependencies `pip install -r requirements.txt`
4. Update the `sascfg_personal.py` file to connect to your SAS instance

The key to using SAS with Jupyter is the functionality of the SAS kernel, which allows SAS programmers to use the Jupyter notebook interface to submit and review the results of SAS code.

This is possible through the SASPy package. There is a configuration step required to tell the SAS Kernel where your SAS is located. SASPy supports connection to all SAS versions released since July 2013. This includes Windows, Linux, SAS Grid, Mainframes, and so on.

The steps to configure a connection between Jupyter and SAS are [here](https://sassoftware.github.io/saspy/install.html#configuration). If you encounter issues please review the [Troubleshooting](https://sassoftware.github.io/saspy/troubleshooting.html) or open an [issue](https://github.com/sassoftware/saspy/issues)

### Documentation

* [SASPy](https://sassoftware.github.io/saspy/)
* [SAS Kernel](https://sassoftware.github.io/sas_kernel/)

### Blogs

* [How to run SAS programs in Jupyter Notebook](https://blogs.sas.com/content/sasdummy/2016/04/24/how-to-run-sas-programs-in-jupyter-notebook/)
* [SAS Tutorial - Using Jupyter to Boost Your Data Science Workflow](https://www.youtube.com/watch?v=mVGJWn9IPcc&list=PLVV6eZFA22Qwahw8r9nilFm1VskGuG0Vf)

### Papers

* [Stepping Up Your SAS Game with Jupyter Notebooks](https://www.sas.com/content/dam/SAS/support/en/sas-global-forum-proceedings/2019/3262-2019.pdf)
* [A Basic Introduction to SASPy and Jupyter Notebooks](https://support.sas.com/content/dam/SAS/support/en/sas-global-forum-proceedings/2018/2822-2018.pdf)
* [A Complete Introduction to SASPy and Jupyter Notebooks](https://www.sas.com/content/dam/SAS/support/en/sas-global-forum-proceedings/2019/3238-2019.pdf)
* [SAS and Python: The Perfect Partners in Crime](https://amadeus.co.uk/assets/White-Papers/SAS-and-Python-The-Perfect-Partners-in-Crime.pdf)
