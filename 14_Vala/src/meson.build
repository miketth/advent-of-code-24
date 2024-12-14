aoc24_sources = [
  'main.vala',
]

aoc24_deps = [
  dependency('glib-2.0'),
  dependency('gio-2.0'),
  dependency('gee-0.8'),
  dependency('gobject-2.0'),
]

executable('aoc24', aoc24_sources,
  vala_args: '--target-glib=2.58',  dependencies: aoc24_deps,
  install: true,
)

