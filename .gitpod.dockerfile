FROM gitpod/workspace-full

RUN sudo apt-get update \
 && sudo apt-get install -y pandoc \
 && python3 -m pip install --upgrade pip \
 && sudo apt install texlive-latex-base \
 && sudo rm -rf /var/lib/apt/lists/*