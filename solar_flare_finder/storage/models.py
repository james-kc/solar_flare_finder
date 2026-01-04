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
)
from sqlalchemy.orm import declarative_base, relationship, validates

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

    @validates("observed", "frac_obs", "frac_obs_rise", "frac_obs_fall")
    def validate_fractions(self, key, value):
        # TODO: This quite likely doesn't work although I don't know how this @validates works

        # Temporarily set the value to self for validation
        temp_values = {
            "observed": value if key == "observed" else getattr(self, "observed", False),
            "frac_obs": value if key == "frac_obs" else getattr(self, "frac_obs", None),
            "frac_obs_rise": (
                value if key == "frac_obs_rise" else getattr(self, "frac_obs_rise", None)
            ),
            "frac_obs_fall": (
                value if key == "frac_obs_fall" else getattr(self, "frac_obs_fall", None)
            ),
        }

        if temp_values["observed"] and all(
            x == 0.0
            for x in [
                temp_values["frac_obs"],
                temp_values["frac_obs_rise"],
                temp_values["frac_obs_fall"],
            ]
        ):
            raise ValueError("observed=True but all fraction values are zero")

        if not temp_values["observed"] and any(
            x != 0.0
            for x in [
                temp_values["frac_obs"],
                temp_values["frac_obs_rise"],
                temp_values["frac_obs_fall"],
            ]
        ):
            raise ValueError("observed=False but fraction values are not zero")

        return value

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
