project(
  'PROJECT_NAME',
  'cpp',
  version : '0.0.1',
  default_options : [
    'buildtype=debugoptimized',
    'b_lto=true',
    'warning_level=2',
    'cpp_std=c++20',
  ],
)

fmtlib = dependency('fmt', include_type : 'system')

subdir('src')
