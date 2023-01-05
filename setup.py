#!/usr/bin/env python
import os
import sys
from setuptools import setup

exec(open("mpsepi/__about__.py").read())

if sys.argv[-1] == "publish":
    os.system("python setup.py sdist upload")
    sys.exit()

with open("README.md") as f:
    long_description = f.read()

packages = ["mpsepi"]
package_data = {
    "mpsepi": [
        "mpsepi/config/*.yaml",
        "mpsepi/envs/*.yaml",
        "mpsepi/snakefiles/*.smk",
        "mpsepi/rules/*.smk",
        "mpsepi/wrappers/*.R",
        "mpsepi/*.py",
    ]
}
data_files = [(".", ["LICENSE", "README.md"])]

entry_points = {"console_scripts": ["mpsepi=mpsepi.corer:main"]}

requires = [
    req.strip()
    for req in open("requirements.txt", "r").readlines()
    if not req.startswith("#")
]

classifiers = [
    "Development Status :: 3 - Alpha",
    "Environment :: Console",
    "Intended Audience :: Developers",
    "Intended Audience :: Science/Research",
    "License :: OSI Approved :: GNU General Public License v3 (GPLv3)",
    "Natural Language :: English",
    "Operating System :: OS Independent",
    "Programming Language :: Python :: 3.7",
    "Programming Language :: Python :: 3.8",
    "Programming Language :: Python :: 3.9",
    "Programming Language :: Python :: 3.10",
    "Topic :: Scientific/Engineering :: Bio-Informatics",
]

setup(
    name="mpsepi",
    version=__version__,
    author=__author__,
    author_email="alienchuj@gmail.com",
    url="https://github.com/ohmeta/mpsepi",
    description="a microbiome data process and visualization pipeline",
    long_description_content_type="text/markdown",
    long_description=long_description,
    entry_points=entry_points,
    packages=packages,
    package_data=package_data,
    data_files=data_files,
    include_package_data=True,
    install_requires=requires,
    license="GPLv3+",
    classifiers=classifiers,
)
