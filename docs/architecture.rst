Architecture Overview
=====================

``solar_flare_finder`` is structured as a layered system with clear separation
between domain logic, data acquisition, orchestration, persistence, and external
interfaces.

This separation is intentional and designed to:

- Keep scientific logic independent of storage
- Allow new instruments to be added cleanly
- Make the pipeline reproducible and testable
- Enable future changes to the database or API without rewriting core logic


Project Structure
-----------------

The project is organised into the following top-level packages:

- ``core`` — Domain logic and scientific rules
- ``instruments`` — Instrument-specific data access and observation logic
- ``pipeline`` — Workflow orchestration
- ``storage`` — Database models and persistence
- ``web`` — External API (FastAPI)


Layer Responsibilities
----------------------

core
^^^^

**Purpose:** Domain logic and scientific meaning

The ``core`` package contains pure Python logic describing what a solar flare is
and how flare observations should be interpreted.

It must not depend on the database, SunPy, or web frameworks.

Typical contents include:

- Flare classification logic (GOES classes, ordering)
- Validation rules (e.g. observed implies non-zero coverage)
- Time window logic (rise, peak, decay)
- Domain-level constants and metadata

If all I/O were removed, this package should still make sense.


instruments
^^^^^^^^^^^

**Purpose:** Instrument-specific data access and observation computation

The ``instruments`` package contains all knowledge of how individual instruments
observe solar flares.

Each instrument module is responsible for:

- Determining whether the instrument was operational
- Querying mission-specific data (e.g. via SunPy)
- Computing observation statistics for a flare

Each instrument exposes a consistent interface, allowing the pipeline to treat
all instruments uniformly.

If a bug affects only one instrument, the fix should live here.


pipeline
^^^^^^^^

**Purpose:** Orchestration and workflow

The ``pipeline`` package coordinates the overall processing flow.

It defines *when* things happen, not *how* they work internally.

Responsibilities include:

- Creating flare records
- Triggering observation computations
- Persisting results to the database
- Handling retries and partial failures

The pipeline depends on ``core``, ``instruments``, and ``storage``.


storage
^^^^^^^

**Purpose:** Persistence and database schema

The ``storage`` package is the only place that interacts with SQL.

It contains:

- SQLAlchemy ORM models
- Database constraints and relationships
- Session and engine setup
- Persistence-level validation

This layer does not contain scientific logic and does not know how observation
statistics are computed.


web
^^^

**Purpose:** External interface (API)

The ``web`` package exposes project data via a FastAPI application.

Responsibilities include:

- Read-only access to flare and observation data
- Filtering, pagination, and serialization
- Pydantic schemas for API responses

The web layer depends on ``storage`` but does not access instrument or pipeline
internals.


Dependency Rules
----------------

The allowed dependency flow is strictly one-directional:

::

    core
    ↑
    instruments
    ↑
    pipeline
    ↑
    web

The ``storage`` package is used by ``pipeline`` and ``web``, but does not depend on
any other project modules.

Disallowed dependencies include:

- ``core`` importing ``storage``
- ``storage`` importing ``instruments``
- ``instruments`` committing to the database


Design Rationale
----------------

This architecture ensures that:

- Scientific logic can evolve independently of storage
- New instruments can be added without modifying existing ones
- The pipeline can be rerun deterministically
- The database schema can change without rewriting computation code

This separation is critical for long-term maintainability and reproducibility.
