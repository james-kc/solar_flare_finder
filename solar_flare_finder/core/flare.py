from dataclasses import dataclass
from datetime import datetime


@dataclass
class SolarFlare:
    """Represents a solar flare event with timing and location data."""

    start: datetime
    """Flare start time (UTC)."""
    peak: datetime
    """Flare peak intensity time (UTC)."""
    end: datetime
    """Flare end time (UTC)."""
    goes_class: str
    """GOES X-ray classification (A, B, C, M, or X)."""
    loc_hgs: str
    """Stonyhurst Heliographic Coordinates (HGS) location."""
    loc_x: float
    """Helioprojective Cartesian X coordinate (arcsec)."""
    loc_y: float
    """Helioprojective Cartesian Y coordinate (arcsec)."""
