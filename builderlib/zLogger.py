# -*- coding: utf-8 -*-
"""
This is an experimental script used for logging in a jass file.

In the future, it can be used to create a call stack (push on enter function, pop on return or endfunction)
"""

in_func = False
done = False

result = []

with open('../development/map/war3map.j') as file:
    for line in file:
        result.append(line)
        line = line.strip()
        if not in_func:
            if line.strip().startswith('function'):
                    name = line[len('function'):line.find('takes')].strip()
                    # print(name)
                    in_func = True
        else:
            if line.strip() == 'endfunction':
                # print('out')
                in_func = False
                done = False
            if name != 'main' and name!= 'config':
                if not done and (line.startswith('set') or line.startswith('call') or line.startswith('if') or line.startswith('loop')):
                    # print('insert')
                    result.insert(-1, 'call PreloadGenClear()\n')
                    result.insert(-1, 'call PreloadGenStart()\n')
                    result.insert(-1, 'call Preload("{}")\n'.format(name))
                    result.insert(-1, 'call PreloadGenEnd("a.txt")\n')
                    done = True
                
with open('../development/map/war3map.j', 'w') as file:
    file.writelines(result)
            

