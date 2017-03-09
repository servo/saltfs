import os
import pwd
import stat

from tests.util import Failure, Success


def get_owner(filename):
    return pwd.getpwuid(os.stat(filename).st_uid).pw_name


def is_world_readable(filename):
    st = os.stat(filename)
    return bool(st.st_mode & stat.S_IROTH)


def run():
    for root, directories, filenames in os.walk('/home/servo/homu/'):
        for filename in filenames:
            full_path = os.path.join(root, filename)
            if get_owner(full_path) != 'homu':
                return Failure('Homu file is not owned by \'homu\' user:',
                               full_path)
            if is_world_readable(full_path):
                return Failure('Homu file is world-readable:', full_path)
    return Success('Homu files have valid permissions')
