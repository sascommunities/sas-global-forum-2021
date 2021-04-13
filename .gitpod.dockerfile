FROM gitpod/workspace-full

RUN sudo apt-get update \
 && sudo apt-get install -y pandoc \
 && sudo apt install -y texlive-latex-base \
 && sudo rm -rf /var/lib/apt/lists/*