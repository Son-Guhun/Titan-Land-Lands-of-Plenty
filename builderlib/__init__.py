import types

def get_user_functions(table):
    """An iterator that returns all user-defined functions in the global namespace."""
    for f in [(f) for f in table.values() if type(f) == types.FunctionType]:
        yield f
