from dataclasses import dataclass


@dataclass
class InstrumentObservation:
    """Represents an observation (or non-obsercation) of a solar flare by a specific instrument."""

    instrument: str
    """Name of the instrument used for observation."""
    observed: bool
    """Whether the flare was observed by this instrument."""
    frac_obs: float | None
    """Fraction of the flare observed (overall)."""
    frac_obs_rise: float | None
    """Fraction of the flare rise phase observed."""
    frac_obs_fall: float | None
    """Fraction of the flare fall phase observed."""
