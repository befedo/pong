#!/usr/bin/env python3
import subprocess
import os

print("Generate Doc.")

#Latex Dokument
for i in range(3):
    print("pdflatex durchlauf: "+str(i+1))
    process = subprocess.Popen(["pdflatex","Dokumentation.tex"],cwd="doc",shell=False, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    process.wait()
    
latexFiles= os.listdir("doc/")
for file in latexFiles:
    if file.count("Dokumentation") > 0:
        if file.count("pdf") == 0 and file.count("tex") == 0:
            os.remove("doc/"+file)

#Doxygen
process = subprocess.Popen(["doxygen","doxygen.conf"], shell=False, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
process.wait()
