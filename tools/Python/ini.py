import os
import pathlib

current_dir=os.path.abspath(__file__)
env_dir=pathlib.Path(current_dir).parent.parent.parent
tmp_dir=env_dir.joinpath('tmp').joinpath('dirlist.txt')
env_dir=str(env_dir).replace('\\','/')

file=open(tmp_dir,'w')
file.write(env_dir+'\n')
file.close()