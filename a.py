from os import walk
from os.path import join
for (curpath, subdirs, filenames) in walk('.'):
    if not curpath: continue
    if curpath.startswith(r'.\.git') or curpath.startswith(r'.\project'): continue
    for filename in filenames:
        print(join(curpath, filename))
        with open(join(curpath, filename), 'rb') as f:
            text=f.read().replace(b'\r\n', b'\n')
        with open(join(curpath, filename), 'wb') as f:
            f.write(text)
