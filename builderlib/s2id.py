"""Used to work with FourCC object codes used by Warcraft III.

Provides a Rawcode class which inherits from str and can be added with integers.
Example: Rawcode('H009') + 2 => Rawcode('H00B')
"""
alphabet = 'abcdefghijklmnpqrstuvwxyz'
dictionary = {k:v for (k,v) in zip(alphabet,range(len(alphabet)))}

def base36encode(number, alphabet='0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'):
    """Converts an integer to a base36 string."""
    if not isinstance(number, (int)):
        raise TypeError('number must be an integer')

    base36 = ''
    sign = ''

    number %= RAWCODE_MAX

    if 0 <= number < len(alphabet):
        return sign + '000' + alphabet[number]

    while number != 0:
        number, i = divmod(number, len(alphabet))
        base36 = alphabet[i] + base36

    return sign + '0'*(4-len(base36)) + base36

def base36decode(number):
    return int(number, 36)

RAWCODE_MAX = int('ZZZZ', 36) + 1

class Rawcode(str):
    
    def __add__(self, n):
        return Rawcode(base36encode(base36decode(self)+n))

    def __repr__(self):
        return "Rawcode('{}')".format(self)
        

class RawcodeSafe(Rawcode):
    
    def __new__(cls, object):
        r = super().__new__(cls, object)
        if len(r) != 4:
            raise ValueError("Rawcode string must be 4 characters long.")
        for char in r:
            if 0 <= ord(char) <= 31 or ord(char) >= 127:
                raise ValueError("Rawcode string must be ASCII.")
        return r

def rawcode_range(init, size):
    """Example: rawcode_range('H000',3) => yields 'H000','H001','H002'"""
    if type('init') == str:
        init = Rawcode(init)
    for i in range(size):
        yield init
        init += 1
