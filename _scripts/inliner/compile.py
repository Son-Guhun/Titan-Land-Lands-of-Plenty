import subprocess,os
def exe(pyfile,dest="dist",creator="C:\\ProgramData\\Anaconda3\\Scripts\\pyinstaller.exe",ico="",noconsole=False):
    insert=""
    if dest: insert+='--distpath "{}"'.format(dest)
    else: insert+='--distpath "" '.format(os.path.split(pyfile)[0])
    if ico: insert+=' --icon="{}" '.format(ico)
    if noconsole: insert+=' --noconsole '
    runstring='"{creator}" "{pyfile}" {insert} -F'.format(**locals())
    subprocess.check_output(runstring)

exe("inliner.py")

