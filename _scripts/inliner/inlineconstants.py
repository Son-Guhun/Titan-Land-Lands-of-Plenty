from globalvars import *


def inline_constants_impl(line):
    is_string = False
    escape = False
    first_slash = False
    is_comment = False
    is_symbol = False
    join_buffer = False
    is_rawcode = False
    
    buffer = []
    noise = []
    symbols = []

    for char in line:
        if first_slash:
            if char == '/':
                is_comment = True
                buffer.append(char)
                continue
            else:
                first_slash = False
        if is_comment:
            buffer.append(char)
            continue
        elif is_string:
            if escape:
                escape = False
            else:
                if char == '\\':
                    escape = True
                elif char == '"':
                    # print(char)
                    is_string = False
                    buffer.append(char)
                    symbols.append(''.join(buffer))
                    buffer.clear()
                    continue 
        elif is_rawcode:
            if char == "'":
                is_rawcode = False
                buffer.append(char)
                symbols.append(''.join(buffer))
                buffer.clear()
                continue
        else:
            if char == '/':
                first_slash = True
            elif char == '"':
                is_string = True
                join_buffer = True
            elif char == "'":
                is_rawcode = True
                join_buffer = True
            elif char in valid_symbol_chars:
                join_buffer = not is_symbol
            else:
                join_buffer = is_symbol
                
        if join_buffer:
            join_buffer = False
            if is_string:
                pass
            if not is_symbol:
                # print(''.join(buffer))
                noise.append(''.join(buffer))

                buffer.clear()
                is_symbol = not is_string and not is_rawcode # String must be followed by non-symbol
                if not is_symbol:
                    pass
                    # print (char)
            else:
                symbol = ''.join(buffer)
                if symbol in constants and symbol not in l_vars:
                    symbols.append('({})'.format(constants[symbol]))
                else:
                    symbols.append(symbol)
                buffer.clear()
                is_symbol = False
        
        buffer.append(char)

    noise.append(''.join(buffer))

    return noise, symbols


def inline_constants(line):
    noise, symbols = inline_constants_impl(line)


    result = []
    for i,v in enumerate(symbols):
        result.append(noise[i]) 
        result.append(v)
    result.append(noise[-1])
    
    return ''.join(result) #, noise, symbols
