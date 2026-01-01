from solar_flare_finder.version import __version__

release = __version__
version = ".".join(__version__.split(".")[:2])


extensions = [
    "sphinx.ext.autodoc",
    "sphinx.ext.napoleon",
]

html_theme = "sphinx_rtd_theme"
