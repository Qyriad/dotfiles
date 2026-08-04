from ctypes import c_uint, c_char_p, c_int, POINTER

from .clib import find_clib

# Think this is correct.
pid_t = c_uint

libsystemd = find_clib('systemd')
libsystemd.sd_pid_get_user_unit.argtypes = [c_int, POINTER(c_char_p)]
libsystemd.sd_pid_get_user_unit.restype = c_int
