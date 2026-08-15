# OBGEL Principles

These principles have emerged from the development of the Open Binary
Gibbs Energy Library. They are intended to guide both the maintainers
and future contributors.

## 1. Demonstrate utility before explaining implementation

Whenever practical, begin with a useful scientific example. Show the
reader what can be done before explaining how the underlying machinery
works.

## 2. Explain why before how

Documentation should explain the scientific or pedagogical reason for
a design before describing its implementation.

## 3. Every example should teach something

OBGEL should grow by adding thermodynamic ideas, not merely by adding
systems. Each curated example should have a reason to exist.

## 4. The Gibbs free energy is the central thermodynamic object

Phase equilibria should be understood as consequences of the Gibbs
free-energy models, rather than treating the phase diagram as the
primary object.

## 5. The canonical JSON is the source of thermodynamic data

The canonical machine-readable representation is the authoritative
source for the numerical thermodynamic model. TeX, PDF, SVG,
Mathematica expressions, and other representations are derived from it.

## 6. Preserve the distinction between a model and its consequences

OBGEL provides documented thermodynamic models of phases. Equilibrium
phase behavior is constructed from those models and should not be
confused with the models themselves.

## 7. Keep the mathematics visible

Reference implementations should produce ordinary symbolic
mathematical expressions whenever practical. Users should be able to
inspect, differentiate, plot, and manipulate the resulting functions
without encountering an opaque computational black box.

## 8. Use real data to drive architectural change

The information model and reference implementations should evolve in
response to demonstrated requirements from real thermodynamic
assessments. Speculative generalizations should be recorded as future
directions rather than implemented prematurely.

## 9. Preserve provenance

Every curated thermodynamic model should be traceable to its source
and should distinguish clearly between published assessments,
secondary reproductions, private communications, and editorial
interpretation.

## 10. Make uncertainty visible

When provenance, interpretation, validity range, or other information
is uncertain, the uncertainty should be documented rather than hidden
or replaced with an unsupported assumption.

## 11. Write for scientists, teachers, students, and developers

OBGEL is simultaneously a scientific reference, a teaching resource,
and a computational library. Documentation should remain rigorous
while being understandable to readers approaching the project from
different backgrounds.

## 12. Leave the next contributor a better starting point

Every contribution should improve not only the collection of data but
also the clarity, reproducibility, and maintainability of the project.
