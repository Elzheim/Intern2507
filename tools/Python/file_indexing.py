import os
import pathlib
import re
import argparse
import pandas as pd

parser=argparse.ArgumentParser(description='Selecting Source')
parser.add_argument('source', type=str, help='insert source name')
args=parser.parse_args()
file_dir=os.path.dirname(os.path.abspath(__file__))
work_dir=pathlib.Path(file_dir).parent.parent
data_dir=work_dir.joinpath('data')
data_dir=data_dir.joinpath(args.source)

data_folder_list=os.listdir(data_dir)

title_data=list()

file_in_folder = list()
for folder in data_folder_list:
    col_dir=data_dir.joinpath(folder)
    file_list = os.listdir(col_dir)
    
    for file in file_list:
        title_split = re.split('[_.]',str(file))
        title_data.append(title_split)

df_title_data = pd.DataFrame(title_data,columns=['topic','year','type'])
df_year=df_title_data.drop_duplicates(subset='year')['year']
df_topic=df_title_data.drop_duplicates(subset='topic')['topic']
df_renewal=pd.DataFrame(df_title_data,index=df_year,columns=df_topic)

for topic in df_topic:
    for year in df_year:
        search = [topic, year,'xpt']
        if search in title_data:
            df_renewal[topic][year] = 1
possible_year = list(df_renewal.dropna(axis=0).index)
selected_file_dir=list()

for topic in data_folder_list:
    tmp_file_dir = data_dir.joinpath(topic)
    for year in possible_year:
        tmp_file_name = topic + '_' + year + '.xpt'
        selected_file_dir.append(tmp_file_dir.joinpath(tmp_file_name))

print(selected_file_dir)
dir = work_dir.joinpath('tmp')
dir= dir.joinpath('filelist.txt')
file = open(dir,'w')
for topic in df_renewal.dropna(axis=0).columns:
    file.write(topic+'\t')
file.write('\n')
for year in df_renewal.dropna(axis=0).index:
    file.write(year+'\t')
file.write('\n')
for name in selected_file_dir:
    file.write(os.fspath(name)+'\n')
file.close()
