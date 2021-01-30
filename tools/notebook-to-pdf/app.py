import os
import argparse
import logging
import json
import tempfile
from distutils import dir_util, file_util
import subprocess
from fileinput import FileInput

logging.basicConfig()
root = logging.getLogger()
handler = root.handlers[0]
handler.setFormatter(logging.Formatter('%(asctime)s [%(levelname)s] - %(message)s'))

variables = []
header = True
footer = True

def populateVariables(file, vars):
    """
    """
    for var in vars:
        subme = '{{'+var[0]+'}}'
        report = FileInput(file, inplace=True)
        for line in report:
            print(line.replace(subme,str(var[1])), end='')
    print('done')

def parseCmdArguments():
    parser = argparse.ArgumentParser(description='Process some integers.')
    
    parser.add_argument(
        '--notebook-dir', 
        metavar='N',
        dest='notebook_dir',
        type=str, 
        nargs=1,
        help='an integer for the accumulator'
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
                    # TODO: strip new lines
                    variables.append(('PAPER_TITLE',cell['source'][0][2:]))
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

def createSrcTex(md_file, tex_file):
    """
    """
    try:
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

def main():
    """
    """
    args = parseCmdArguments()

    # validate notebook metadata
    # extract cells based on metadata
    
    # populate variables in tex file
    # create PDF


    for nd in args.notebook_dir:
        for file in os.listdir(nd):
            if file.endswith(".ipynb"):
                    with tempfile.TemporaryDirectory() as td:
                        print('Creating everything in ' + td)

                        dir_util.copy_tree(nd, td)
                        file_util.copy_file('header.tex', td)
                        file_util.copy_file('sugconf.cls', td)
                        file_util.copy_file('sasbanner.png', td)

                        home = os.getcwd()
                        os.chdir(td)


                        if validateNotebook(file):
                            variables, markdown = extractNotebookData(file, td)
                            
                            md_file = file[:-6] + ".md"
                            tex_file = file[:-6] + ".tex"
                            pdf_file = file[:-6] + ".pdf"

                            full_tex = os.path.join(td,tex_file)

                            # writeMarkdownTempFile('/'.join([md_file,file]), markdown)
                            writeMarkdownTempFile(md_file, markdown)
                            try:
                                createSrcTex(md_file, tex_file)
                                createSgfTex(tex_file)
                                populateVariables(full_tex, variables)
                                createPdf(full_tex)
                                
                                file_util.copy_file(pdf_file, home)
                            except Exception as e:
                                print(str(e))

if __name__ == '__main__':
    main()