from globalvars import *
from inlineconstants import *
import sys



def starts_with(string, substring):
    return string[:len(substring)] == substring

def is_const(value):
    value = value.strip().strip('()')
    for char in value:
        if char in operators:
            return False
    return True
    

def get_rlvalues(line):
    line = line.strip()
    i = line.find('//')
    if i != -1:
        line = line[:i]

    line = line.split('=')
    line = tuple(x.strip() for x in line)
    return line

def parse_constant(line):
    rvalue, lvalue = get_rlvalues(line)

    const ,type, name = rvalue.split()

    if type in ['integer', 'real', 'boolean']:
        if is_const(lvalue):
            constants[name] = lvalue.strip()
            return True
    return False

def parse_local(line):
    rvalue = get_rlvalues(line)[0]

    name = rvalue.split()[-1]

    l_vars.add(name)

def parse_parameters(line):
    params = line[line.find('takes')+len('takes'):line.find('returns')]

    params = params.strip()

    if params != 'nothing':
        params = params.split(',')
        for i in range(len(params)):
            params[i] = params[i].strip()
            params[i] = params[i].split()

        for type,name in params:
            l_vars.add(name)

def parse(file, out=sys.stdout):
    in_locals = False
    in_function = False
    in_globals = True

    for line in file:
        stripped = line.strip()

        if in_globals:
            if starts_with(stripped, "constant "):
                line = inline_constants(line)
                if parse_constant(line):
                    line = ''
            elif starts_with(stripped, "endglobals"):
                in_globals = False
            else:
                line = inline_constants(line)
        elif in_locals:
            if starts_with(stripped, "local"):
                line = inline_constants(line)
                parse_local(line)
            elif stripped != '':
                in_locals = False
                in_function = True
        if in_function:
            if stripped:
                if starts_with(stripped, "endfunction"):
                    in_locals = False
                    in_function = False
                    l_vars.clear()
                    #out.write(line)

                else:
                    try:
                        line = inline_constants(line)
                    except Exception as e:
                        sys.stderr.write(line)
                        raise e
        else: 
            if starts_with(stripped, 'function') or starts_with(stripped, 'constant function'):
                in_locals = True
        
        if line:
            out.write(line)

def inline_strings(file, out):
    is_string = False
    for line in file:
        escape = False
        first_slash = False
        for char in line:
            if first_slash and char == '/':
                break
            first_slash = False
            if is_string:
                if escape:
                    escape = False
                else:
                    if char == '\\':
                        escape = True
                    elif char == '"':
                        is_string = False
            else:
                if char == '/':
                    first_slash = True
                elif char == '"':
                    is_string = True
        if is_string:
            out.write(line[:-1]+'\\n')
        else:
            out.write(line)

def do(file='test.j', out=sys.stdout): 
    constants.clear()
    l_vars.clear()  # not needed if the last execution was successful
    with open(file,'r') as f:
        with open('temp.j','w') as temp:
            inline_strings(f, temp)
    with open('temp.j','r') as temp:
        parse(temp, out)


import os

def up(path, n=1, lastSeparator=True):
    return os.path.abspath(os.path.join(path ,"/".join(['..' for i in range(n)]))) \
+ (os.path.sep if lastSeparator else '')

FROZEN = getattr(sys, 'frozen', '')

if not FROZEN:
    # not frozen: in regular python interpreter
    DIRECTORY = up(sys.argv[0],1)

elif FROZEN in ('dll', 'console_exe', 'windows_exe'):
    # py2exe:
    DIRECTORY = up(sys.executable,1)
    
elif FROZEN in ('macosx_app',):
    # py2app:
    # Notes on how to find stuff on MAC, by an expert (Bob Ippolito):
    # http://mail.python.org/pipermail/pythonmac-sig/2004-November/012121.html
    DIRECTORY = os.environ['RESOURCEPATH']

elif FROZEN == True:
    #pyinstaller
    DIRECTORY = up(sys.executable,1)

if FROZEN:
    import subprocess

    print(FROZEN)
    print(DIRECTORY)

    if len(sys.argv) < 2:
        w3x = os.path.abspath('test.w3x')
    else:
        w3x = os.path.abspath(sys.argv[1])

        if '-replace' in sys.argv:
            replace = True

    if w3x[w3x.rfind('.'):] == '.j':
        with open(w3x[:w3x.rfind('.')]+'-opt.j','w') as f:
            do(w3x, f)
        
        if replace:
            os.remove(w3x)
            os.rename(w3x[:w3x.rfind('.')]+'-opt.j', w3x)
    else:
        p = subprocess.Popen(['MPQEditor','e',w3x,'war3map.j',DIRECTORY+'war3map.j'])
        p.wait()

        with open(DIRECTORY+'war3map-opt.j','w') as f:
            do(DIRECTORY+'war3map.j\\war3map.j', f)

        p = subprocess.Popen(['MPQEditor','d',w3x,'war3map.j'])
        p.wait()
        p = subprocess.Popen(['MPQEditor','f',w3x])
        p.wait()
        p = subprocess.Popen(['MPQEditor','a',w3x,DIRECTORY+'war3map-opt.j','war3map.j'])
        p.wait()

        p = subprocess.Popen(['MPQEditor','e',w3x,'war3map.j',DIRECTORY+'war3map-new.j'])
        p.wait()
