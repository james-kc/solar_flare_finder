# core/flare.py
from dataclasses import dataclass
from datetime import datetime

@dataclass
class Flare:
    start: datetime
    peak: datetime
    end: datetime
    goes_class: str
    location: str
    noaa_ar: int | None
