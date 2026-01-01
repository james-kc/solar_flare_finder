# instruments/base.py
from abc import ABC, abstractmethod

class Instrument(ABC):
    name: str

    @abstractmethod
    def observed(self, flare):
        """Return True/False"""

    @abstractmethod
    def observation_fraction(self, flare):
        """Return (total, rise, fall) fractions"""
