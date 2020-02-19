alphabet = 'abcdefghijklmnopqrstuvwxyz'
numeric = '1234567890'
valid_symbol_chars = set(alphabet+alphabet.upper()+numeric+'_'+'$')
constants = {}
l_vars = set()
operators = set('+-/*')


inside_string = True