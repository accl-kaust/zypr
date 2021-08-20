import pytest

@pytest.fixture(autouse=True)
def run_around_tests():
    # Code that will run before your test, for example:
    # files_before = # ... do something to check the existing files
    print('befpre')
    
    # A test function will be run at this point
    yield
    # Code that will run after your test, for example:
    # files_after = # ... do something to check the existing files
    # assert files_before == files_after
    print('after')

def capital_case(x):
    return x.capitalize()

def test_capital_case():
    assert capital_case('semaphore') == 'Semaphore'