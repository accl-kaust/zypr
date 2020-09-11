from zycap import linux

def capital_case(x):
    f = linux.build()
    return x.capitalize()

def test_capital_case():
    assert capital_case('semaphore') == 'Semaphore'