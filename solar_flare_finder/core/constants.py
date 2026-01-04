"""
Global constants and schema definitions for solar_flare_finder.

This module defines:
- Database table and column contracts
- Instrument registry and capabilities
- Flare classification metadata
- Sentinel values for missing data
- Validation helpers for instrument observations

All values here should be treated as READ-ONLY.
"""

from dataclasses import dataclass
from typing import Dict, Set
from datetime import datetime


#############################
# MISSING / SENTINEL VALUES #
#############################

MISSING_FLOAT = float("nan")
MISSING_INT = -1
MISSING_BOOL = False


########################
# FLARE CLASSIFICATION #
########################

# Order used for sorting / comparison
FLARE_CLASS_ORDER = ["A", "B", "C", "M", "X"]

# Minimum peak flux (W m^-2) for each GOES class
FLARE_CLASS_MIN_FLUX = {
    "A": 1e-8,
    "B": 1e-7,
    "C": 1e-6,
    "M": 1e-5,
    "X": 1e-4,
}


###################
# DATABASE TABLES #
###################

FLARES_TABLE = "flares"
INSTRUMENT_OBS_TABLE = "instrument_observations"


############################
# INSTRUMENT SPECIFICATION #
############################


@dataclass(frozen=True)
class InstrumentSpec:
    """
    Defines the observational capabilities and operational lifetime of an instrument.
    """

    code: str
    operational_start: datetime
    operational_end: datetime | None
    has_flare_flag: bool = False


#######################
# INSTRUMENT REGISTRY #
#######################

INSTRUMENTS: Dict[str, InstrumentSpec] = {
    "RHESSI": InstrumentSpec(
        code="RHESSI",
        operational_start=datetime(2002, 2, 15),
        operational_end=datetime(2018, 8, 16),
        has_flare_flag=True,
    ),
    "MEGSA": InstrumentSpec(
        code="MEGSA",
        operational_start=datetime(2010, 4, 30),
        operational_end=datetime(2014, 5, 27),
    ),
    "MEGSB": InstrumentSpec(
        code="MEGSB",
        operational_start=datetime(2010, 4, 30),
        operational_end=None,
    ),
    "EIS": InstrumentSpec(
        code="EIS",
        operational_start=datetime(2006, 9, 26),
        operational_end=None,
    ),
    "SOT": InstrumentSpec(
        code="SOT",
        operational_start=datetime(2006, 9, 26),
        operational_end=None,
    ),
    "XRT": InstrumentSpec(
        code="XRT",
        operational_start=datetime(2006, 9, 26),
        operational_end=None,
    ),
    "IRIS": InstrumentSpec(
        code="IRIS",
        operational_start=datetime(2013, 7, 17),
        operational_end=None,
    ),
    "FERMI": InstrumentSpec(
        code="FERMI",
        operational_start=datetime(2008, 6, 11),
        operational_end=None,
    ),
}


############################
# INSTRUMENT FIELD RULES #
############################


def allowed_obs_fields(spec: InstrumentSpec) -> Set[str]:
    """
    Return the set of observation fields that are scientifically
    meaningful for a given instrument.

    Used for:
    - pipeline validation
    - database insert logic
    - query construction
    - denormalised view generation
    """
    fields: Set[str] = {"observed"}

    if spec.has_flare_flag:
        fields.add("flare_flag")

    return fields
