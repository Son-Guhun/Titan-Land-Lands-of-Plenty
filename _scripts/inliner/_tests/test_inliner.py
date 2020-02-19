import inliner
import subprocess

PJASS = '_tests\\pjass.exe'
COMMON = '..\..\development\scripts\common.j'
BLIZZARD = '..\..\development\scripts\common.jblizzard.j'

def test_inliner():
    with open('_tests\\test-opt.j','w') as f:
        inliner.do(out=f)


    result = subprocess.Popen([ PJASS, COMMON, BLIZZARD, '_tests\\test-opt.j'] ).wait()
    
    assert (result == 0)
