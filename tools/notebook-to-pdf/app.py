import os
import json
import tempfile
from distutils.dir_util import copy_tree
import subprocess

def getNotebooks():
    """
    get-all the notebooks to convert
    iterate the papers folder looking for checkpoint subfolder
    if found, previous folder entry must be a notebook entry
    """
    notebooks = []
    dirs = [x[0] for x in os.walk("../../papers")]
    del dirs[0]
    i=0
    for d in dirs:
        if ".ipynb_checkpoints" in d:
            notebooks.append(dirs[i-1])
        i=i+1

    return notebooks

def createMarkdownSource(file, td):
    """
    """

    markdown = []
    with open(file, 'r') as f:
        data = json.load(f)
    
    cells = data['cells']
    for cell in cells:

        # skip cells that we know we want to remove
        if 'tags' in cell['metadata']:
            if 'remove_cell' in cell['metadata']['tags']:
                continue
        
        # markdown cells
        if cell['cell_type'] == 'markdown':
            markdown.append('\n')
            for item in cell['source']:
                if '![]' in item:
                    x = item[4:]
                    y = '![](' + td + '/' + x
                    markdown.append(y)
                else:
                    markdown.append(item)
            # markdown.append(''.join(cell['source']))
            markdown.append('\n')

        # code cells
        if cell['cell_type'] == 'code':
            markdown.append('\n')
            markdown.append(''.join(['```sas\n',''.join(cell['source']),'\n```\n']))
            markdown.append('\n')

    return markdown

def writeMarkdownTempFile(file, markdown):
    try:
        with open(file, 'w') as f:
            f.writelines(markdown)
        return True
    except:
        return False

def createPdf(mdfile, pdffile):

    data = subprocess.run([
        'pandoc',
        '-o', 
        pdffile,
        mdfile
    ], stdout=subprocess.PIPE)
    data = data.stdout.decode('utf8')


def main():
    ndirs = getNotebooks()
    for nd in ndirs:
        for file in os.listdir(nd):
            if file.endswith(".ipynb"):
            
                with tempfile.TemporaryDirectory() as td:
                    mdfile = file[:-6] + ".md"
                    pdffile = file[:-6] + ".pdf"

                    # copy contents to tempdir
                    copy_tree(nd, td)

                    markdown = createMarkdownSource('/'.join([td, file]), td)

                    writeMarkdownTempFile('/'.join([td,mdfile]), markdown)
                    createPdf('/'.join([td, mdfile]), '/'.join([td, pdffile]))
                    print("tada")

main()