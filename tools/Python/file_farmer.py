import os
import pathlib
import re
import argparse
import pandas as pd

parser=argparse.ArgumentParser(description='Selecting Source')
parser.add_argument('source', type=str, help='insert source name')
parser.add_argument('--sub',type=str, nargs='*')
args=parser.parse_args()
file_dir=os.path.dirname(os.path.abspath(__file__))
work_dir=pathlib.Path(file_dir).parent.parent
data_dir=work_dir.joinpath('data')
data_dir=data_dir.joinpath(args.source)
set_subject= args.sub
files=list()
for subject in set_subject:
    if subject in os.listdir(data_dir):
        subject_dir=data_dir.joinpath(subject)
        

