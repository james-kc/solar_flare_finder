"""
Version access for solar_flare_finder.

The canonical version is defined in pyproject.toml.
"""

from importlib.metadata import version, PackageNotFoundError

try:
    __version__ = version("solar-flare-finder")
except PackageNotFoundError:
    # Allows importing from source tree without installation
    __version__ = "0.0.0+unknown"
