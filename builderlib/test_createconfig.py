from builder import generate_config, config_values
import os
import configparser

def test_1(delete=True):
    generate_config('config-test.ini')
    assert os.path.exists('config-test.ini')

    parser = configparser.ConfigParser()
    parser.read('config-test.ini')

    for section in config_values:
        for option,value in config_values[section].items():
            assert parser[section][option] == value

    if delete:
        os.remove('config-test.ini')
