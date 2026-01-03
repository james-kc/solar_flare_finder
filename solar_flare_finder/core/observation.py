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

    def __post_init__(self):
        if self.observed and all(
            x is None for x in [self.frac_obs, self.frac_obs_rise, self.frac_obs_fall]
        ):
            raise ValueError("observed=True but all fraction values are None")
        elif not self.observed and any(
            x is not None for x in [self.frac_obs, self.frac_obs_rise, self.frac_obs_fall]
        ):
            raise ValueError("observed=False but fraction values are provided")
