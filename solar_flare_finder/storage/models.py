"""
SQLAlchemy ORM models for solar_flare_finder.

Defines the database schema for:
- flares
- instrument_observations

These models map directly to the normalized SQL tables and
should contain NO pipeline or business logic.
"""

from sqlalchemy import (
    Column,
    Integer,
    String,
    Float,
    Boolean,
    DateTime,
    ForeignKey,
    UniqueConstraint,
    Index,
    event,
)
from sqlalchemy.orm import declarative_base, relationship

from solar_flare_finder.core.constants import (
    FLARES_TABLE,
    INSTRUMENT_OBS_TABLE,
)

Base = declarative_base()


################
# FLARES TABLE #
################


class Flare(Base):
    __tablename__ = FLARES_TABLE

    id = Column(Integer, primary_key=True)

    flare_start = Column(DateTime, nullable=False, index=True)
    flare_peak = Column(DateTime, nullable=False, index=True)
    flare_end = Column(DateTime, nullable=False, index=True)

    # GOES classification
    class_ = Column("class", String, nullable=False)
    class_letter = Column(String(1), nullable=False, index=True)
    class_mag = Column(Float, nullable=False)

    # Metadata
    noaa_ar = Column(Integer, nullable=True, index=True)

    # Helioprojective coordinates (arcsec)
    hpc_x = Column(Float, nullable=True)
    hpc_y = Column(Float, nullable=True)

    # Heliographic coordinates (lat/lon)
    hgs_x = Column(Float, nullable=True)
    hgs_y = Column(Float, nullable=True)

    # Relationship to instrument observations
    instrument_observations = relationship(
        "InstrumentObservation",
        back_populates="flare",
        cascade="all, delete-orphan",
        lazy="selectin",
    )

    __table_args__ = (Index("ix_flares_class_full", "class_letter", "class_mag"),)

    def __repr__(self) -> str:
        return f"<Flare(id={self.id}, " f"class={self.class_}, " f"start={self.flare_start})>"


#################################
# INSTRUMENT OBSERVATIONS TABLE #
#################################


class InstrumentObservation(Base):
    __tablename__ = INSTRUMENT_OBS_TABLE

    id = Column(Integer, primary_key=True)

    flare_id = Column(
        Integer,
        ForeignKey(f"{FLARES_TABLE}.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )

    # Instrument identifier (must match constants.INSTRUMENTS keys)
    instrument = Column(String, nullable=False, index=True)

    # Core observation flags
    observed = Column(Boolean, nullable=False)
    flare_flag = Column(Boolean, nullable=True)

    # Fractional coverage
    frac_obs = Column(Float, nullable=False)
    frac_obs_rise = Column(Float, nullable=False)
    frac_obs_fall = Column(Float, nullable=False)

    # Relationship back to flare
    flare = relationship(
        "Flare",
        back_populates="instrument_observations",
        lazy="joined",
    )

    __table_args__ = (
        # One row per flare per instrument
        UniqueConstraint(
            "flare_id",
            "instrument",
            name="uq_flare_instrument",
        ),
        Index(
            "ix_obs_instrument_observed",
            "instrument",
            "observed",
        ),
    )

    def __repr__(self) -> str:
        return (
            f"<InstrumentObservation("
            f"flare_id={self.flare_id}, "
            f"instrument={self.instrument}, "
            f"observed={self.observed})>"
        )


@event.listens_for(InstrumentObservation, "before_insert")
@event.listens_for(InstrumentObservation, "before_update")
def validate_fractions(mapper, connection, target):
    """
    Ensure that fraction fields are consistent with observed flag.

    - If observed=True, at least one fraction should be nonzero
    - If observed=False, all fractions must be zero or None
    """
    fracs = [target.frac_obs, target.frac_obs_rise, target.frac_obs_fall]

    if target.observed and all(x == 0.0 for x in fracs):
        raise ValueError("observed=True but all fraction values are 0.0")

    if (
        not target.observed
        and target.frac_obs != 0.0
        and any(x != 0.0 for x in [target.frac_obs_rise, target.frac_obs_fall])
    ):
        raise ValueError("observed=False but fraction values are nonzero")
