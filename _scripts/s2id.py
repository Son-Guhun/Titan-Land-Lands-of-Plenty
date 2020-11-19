"""
Used to work with FourCC's (four character codes) used by Warcraft III to identify objects.

Provides a Rawcode class which inherits from str and can be added with integers.
Examples: 
    - Rawcode('H009') + 2           => Rawcode('H00B')    # Considers only alphanumeric rawcodes.
    - Rawcode('hfoo').to_int()      => 130701168          # Returns in-game value of rawcode.
    - Rawcode('Hart').match('abAB') => Rawcode('haRT')    # Matches capitalization of another rawcode.
    - Rawcode('Hart').match('0000') => Rawcode('HART')    # Numbers are considered uppercase.
"""
import string

alphabet = '0123456789' + string.ascii_lowercase

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


from weakref import WeakValueDictionary

class Rawcode(str):

    _objects = WeakValueDictionary()
    _chars = set(alphabet + alphabet.upper())

    def __new__(cls, object):
        r = super().__new__(cls, object)
        chars = cls._chars

        if r in cls._objects:
            return cls._objects[r]
        
        if len(r) != 4:
            raise ValueError("Rawcode string must be 4 characters long.")

        if not(r[0] in chars and r[1] in chars and r[2] in chars and r[3] in chars):
            raise ValueError("Rawcode string must be alphanumeric.")

        cls._objects[r] = r

        return r
    
    def __add__(self, n):
        return Rawcode(base36encode(base36decode(self)+n))

    def __repr__(self):
        return "Rawcode('{}')".format(self)

    def to_int(self):
        return ord(self[0])*16777216 + ord(self[1])*65536 + ord(self[2])*256 + ord(self[3])

    def match(self, other):
        r = ''.join([
            self[0].lower() if other[0].islower() else self[0].upper(),
            self[1].lower() if other[1].islower() else self[1].upper(),
            self[2].lower() if other[2].islower() else self[2].upper(),
            self[3].lower() if other[3].islower() else self[3].upper()
        ])

        return self if self == r else type(self)(r)

    def match_first(self, other):
        r = ''.join([
            self[0].lower() if other[0].islower() else self[0].upper(),
            self[1],self[2],self[3]
        ])

        return self if self == r else type(self)(r)


# Declare RawcodeSafe class for compatability
RawcodeSafe = Rawcode


def rawcode_range(init, size):
    """Example: rawcode_range('H000',3) => yields 'H000','H001','H002' as Rawcodes"""
    if type('init') == str:
        init = Rawcode(init)
    for i in range(size):
        yield init
        init += 1
