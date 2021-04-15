import os
import argparse
import logging
import json
import tempfile
from distutils import dir_util, file_util
import subprocess
from fileinput import FileInput
import logging
import frontmatter

logging.basicConfig()
root = logging.getLogger()
handler = root.handlers[0]
handler.setFormatter(logging.Formatter('%(asctime)s [%(levelname)s] - %(message)s'))

variables = []
header = True
footer = True

def configure_logging(verbose):
    """
    """
    # required to get the hack below about changing the root logger
    logging.basicConfig()

    root = logging.getLogger()
    handler = root.handlers[0]
    handler.setFormatter(logging.Formatter('%(asctime)s [%(levelname)s] - %(message)s'))
    if verbose:
        logging.getLogger().setLevel(logging.DEBUG)
    else:
        logging.getLogger().setLevel(logging.INFO)

    logging.debug("Logging initalized.")

def str2bool(v):
    """
    """
    if isinstance(v, bool):
        return v
    if v.lower() in ('True', 'yes', 'true', 't', 'y', '1'):
        return True
    elif v.lower() in ('False', 'no', 'false', 'f', 'n', '0'):
        return False
    else:
        raise argparse.ArgumentTypeError('Boolean value expected.')

def populateVariables(file, vars):
    """
    """
    for var in vars:
        subme = '{{'+var[0]+'}}'
        report = FileInput(file, inplace=True)
        for line in report:
            print(line.replace(subme,str(var[1])), end='')

def parseCmdArguments():
    parser = argparse.ArgumentParser(description='You _can_ export the Jupyter Notebooks to PDF (via LaTex) but when you do that through the notebook the styles are not applied. This tool allows us to apply the SGF paper styling from the sugconf latex class (with a couple of modifications for the quirks of Markdown).')
    
    parser.add_argument(
        '--notebook-dir', 
        metavar='d',
        dest='notebook_dir',
        type=str, 
        nargs=1,
        help='The directory which contains the notebook and the supporting files'
    )

    parser.add_argument(
        '--output-dir', 
        metavar='o',
        dest='output_dir',
        type=str, 
        nargs=1,
        help='The directory where the PDF and Tex (see --include-tex) files should be copied to.'
    )

    parser.add_argument(
        '--include-tex', 
        metavar='t',
        dest='include_tex',
        default=False,
        type=str2bool,
        const=True,
        nargs='?',
        help='For debugging, manual adjustment '
    )

    parser.add_argument(
        '--markdown-file', 
        metavar='m',
        dest='markdown_source',
        type=str,
        nargs=1,
        help='Use this argument if you want to make a SGF paper from markdown and not a notebook. Full path to file required.'
    )

    parser.add_argument(
        '--bibliography', 
        metavar='b',
        dest='bib_source',
        type=str,
        nargs=1,
        help='Use this argument if you want to pass in a bibliography for references.'
    )

    parser.add_argument(
        '--csl', 
        metavar='c',
        dest='csl_source',
        type=str,
        nargs=1,
        help='Use this argument if you want to pass in your own CSL for formatting references.'
    )

    return parser.parse_args()

def validateNotebook(notebook):
    """
    """
    return True

def writeMarkdownTempFile(file, markdown):
    try:
        with open(file, 'w') as f:
            f.writelines(markdown)
        return True
    except:
        return False

def extractNotebookData(notebook, td):
    """
    """

    variables = []
    paper_data = []
    global header
    global footer

    def extractMarkdown(cell):

        paper_data.append('\n')
        for item in cell['source']:
            if '![]' in item:
                x = item[4:]
                y = '![](' + td + '/' + x
                paper_data.append(y)
            else:
                paper_data.append(item)
        paper_data.append('\n')
        return True

    def extractCode(cell):
        paper_data.append('\n')
        paper_data.append(''.join(['```sas\n',''.join(cell['source']),'\n```\n']))
        paper_data.append('\n')

        # TODO: Workout how to possible include text/html things from display_data nodes       
        # TODO: Decide if it is worth including stream data (log)?     

        return True

    with open(notebook, 'r') as f:
        data = json.load(f)
    
    cells = data['cells']
    for cell in cells:
        if 'tags' in cell['metadata']:
            if cell['cell_type'] == 'markdown':

                if 'remove_cell' in cell['metadata']['tags']:
                    continue 
                # banner
                if 'banner' in cell['metadata']['tags']:
                    continue 

                # authors
                if 'authors' in cell['metadata']['tags']:
                    variables.append(('PAPER_AUTHORS', ''.join(cell['source']) ))
                    continue

                # paper number
                if 'paper_number' in cell['metadata']['tags']:
                    variables.append(('PAPER_NUMBER', cell['source'][0][7:]))
                    continue
                
                # title
                if 'title' in cell['metadata']['tags']:
                    title = cell['source'][0][2:].replace('\n','')
                    variables.append(('PAPER_TITLE',title))
                    continue
                
                # abstract
                if 'abstract' in cell['metadata']['tags']:
                    variables.append(('PAPER_ABSTRACT',cell['source']))
                    continue

                # trademarks
                if 'trademarks' in cell['metadata']['tags']:
                    footer = False


                # contact_information
                # introduction
                # conclusion
                # references
                # acknowledgements
                # recommended_reading
                # others....
                extractMarkdown(cell)


        else:
            # markdown cells
            if cell['cell_type'] == 'markdown':
                extractMarkdown(cell)

            # code cells
            if cell['cell_type'] == 'code':
                extractCode(cell)

    return variables, paper_data

def createSrcTex(md_file, tex_file, references, csl):
    """
    """
    try:
        if references is not None:

            if csl is None:
                csl = os.path.join(os.getcwd(), 'american-medical-association.csl')
            else:
                csl = os.path.join(os.getcwd(), csl)

            data = subprocess.run([
                'pandoc',
                '--filter',
                'pandoc-citeproc',
                '-s', 
                md_file,
                '--bibliography',
                references[0],
                '--csl',
                csl,
                '-o',
                tex_file
            ], stdout=subprocess.PIPE)
            if data.returncode == 0:
                return True
            else:
                return data.stdout.decode('utf8')
        else:
            data = subprocess.run([
                'pandoc',
                '-s', 
                md_file,
                '-o',
                tex_file
            ], stdout=subprocess.PIPE)
            if data.returncode == 0:
                return True
            else:
                return data.stdout.decode('utf8')            

    except Exception as e:
        print(str(e))

def createSgfTex(tex_file):
    """
    """
    try:

        with open('header.tex', 'r') as f:
            header = f.readlines()

        with open(tex_file, "r+") as f:
            lines = f.readlines()
            f.seek(0)
            f.truncate()
            n=0
            for line in lines:
                if n > 0:
                    break
                if line.strip("\n") == "\\begin{document}":
                    n = lines.index(line)
                    break
            lines = lines[n:]
            tex_data = header + lines
            f.writelines(tex_data)
        

    except Exception as e:
        print(str(e))

def createPdf(tex_file):

    try:
        data = subprocess.run([
            'pdflatex',
            '-interaction',
            'nonstopmode',
            tex_file
        ], stdout=subprocess.PIPE)
        if data.returncode == 0:
            return True
        else:
            return data.stdout.decode('utf8')        
    except Exception as e:
        print(str(e))

def htmlEntities(tex_file):

    entities = {
        "&nbsp;":"nobreakspace",
        "&lt;":"$\leq$",
        "&gt;":"$>$",
        "&cent;":"\textcent",
        "&pound;":"\textsterling",
        "&yen;":"\textyen",
        "&euro;":"\texteuro",
        "&copy;":"\copy",
        "&reg;":"\circledR"
    }

    with open(tex_file, 'r') as reader:
        file = reader.readlines()

    with open(tex_file, 'w') as writer:
        for line in file:
            for key in entities:
                value = entities[key]
                if key in line:
                    line = line.replace(key, value)
            writer.write(line)

    return True

def main():
    """
    """
    output_dir = None
    notebook_dir = None
    args = parseCmdArguments()

    if args.notebook_dir is not None:
        if not os.path.exists(args.notebook_dir):
            logging.error("Output directory {} does not exist".format(args.notebook_dir[0]))
            system.exit(1)
        else:
            notebook_dir =args.notebook_dir[0]

    if args.output_dir is not None:
        if not os.path.exists(args.output_dir[0]):
            logging.error("Output directory {} does not exist".format(args.output_dir[0]))
            system.exit(1)
        else:
            output_dir= args.output_dir[0]
    else:
        if notebook_dir is not None:
            output_dir = notebook_dir
        else:
            output_dir = os.path.dirname(args.markdown_source[0])
    output_dir = os.path.abspath(output_dir)
      
    # TODO: validate notebook metadata

    if args.markdown_source is not None and os.path.exists(args.markdown_source[0]):
        with tempfile.TemporaryDirectory() as td:
            logging.info('Creating everything in ' + td)

            if args.bib_source is not None:
                file_util.copy_file(args.bib_source[0], td)

            if args.csl_source is not None:
                file_util.copy_file(args.csl_source[0], td)
                csl_file = os.path.basename(args.csl_source[0])
            else: 
                csl_file = None

            file_util.copy_file(args.markdown_source[0], td)
            file_util.copy_file('american-medical-association.csl', td)
            file_util.copy_file('header.tex', td)
            file_util.copy_file('sugconf_jupyter.cls', td)
            file_util.copy_file('sasbanner.png', td)

            home = os.getcwd()
            os.chdir(td)

            md_file = os.path.join(td, os.path.basename(args.markdown_source[0]) )
            tex_file = md_file[:-3] + ".tex"
            pdf_file = tex_file[:-4] + ".pdf"

            full_tex = os.path.join(td,tex_file)

            try:
                paper = frontmatter.load(md_file)
                variables = []
                for v in paper.metadata:
                    variables.append((v,paper.metadata[v]))
                createSrcTex(md_file, tex_file, args.bib_source, csl_file)
                createSgfTex(tex_file)
                populateVariables(full_tex, variables)
                htmlEntities(full_tex)
                createPdf(full_tex)
                
                file_util.copy_file(pdf_file, output_dir)
                print("{} created in {}".format(os.path.basename(pdf_file), output_dir))
                if args.include_tex:
                    file_util.copy_file(tex_file, output_dir)
                    print("{} file stored in {}".format(os.path.basename(tex_file), output_dir))

            except Exception as e:
                print(str(e))

            os.chdir(home)
    
    if args.notebook_dir is not None and os.path.exists(args.notebook_dir[0]):
        nd = args.args.notebook_dir[0]
        for file in os.listdir(nd):
            if file.endswith(".ipynb"):
                    with tempfile.TemporaryDirectory() as td:
                        print('Creating everything in ' + td)

                        dir_util.copy_tree(nd, td)
                        file_util.copy_file('header.tex', td)
                        file_util.copy_file('sugconf_jupyter.cls', td)
                        file_util.copy_file('sasbanner.png', td)

                        home = os.getcwd()
                        os.chdir(td)


                        if validateNotebook(file):
                            variables, markdown = extractNotebookData(file, td)
                            
                            md_file = file[:-6] + ".md"
                            tex_file = file[:-6] + ".tex"
                            pdf_file = file[:-6] + ".pdf"

                            full_tex = os.path.join(td,tex_file)

                            writeMarkdownTempFile(md_file, markdown)
                            try:
                                createSrcTex(md_file, tex_file, args.bib_source)
                                createSgfTex(tex_file)
                                populateVariables(full_tex, variables)
                                createPdf(full_tex)
                                
                                file_util.copy_file(pdf_file, args.output_dir[0])
                                if args.include_tex:
                                    file_util.copy_file(tex_file, args.output_dir[0])

                            except Exception as e:
                                print(str(e))

                        os.chdir(home)

if __name__ == '__main__':
    main()