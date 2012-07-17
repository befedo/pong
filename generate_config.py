
#!/usr/bin/env python3

import subprocess
import os

print("Generate Doc.")


process = subprocess.Popen(["doxygen","doxygen.conf"], shell=False, stdout=subprocess.PIPE, stderr=subprocess.PIPE)