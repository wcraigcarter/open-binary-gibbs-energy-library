# Project Notebook

This notebook records significant design decisions, observations, and unresolved questions for the Open Binary Gibbs Energy Library. It is deliberately separate from the README: the README describes the project as it currently stands, while this notebook records why important choices were made and what remains undecided.

---

## 2026-08-12 — Initial repository structure

### Context

The project began as a teaching-oriented collection of explicit molar Gibbs free-energy models intended to support a Mathematica phase-diagram teaching tool. The first architectural goal was to keep the thermodynamic data independent of the visualization application.

### Decision

Keep the repository name and path convention lowercase and hyphenated, with no spaces in directory or file names.

### Reason

Predictable paths are easier to use from code, command-line tools, Git, URLs, and multiple operating systems.

### Decision

Prefer descriptive names over abbreviations.

### Reason

Scientific repositories benefit from names that reveal physical meaning and remain understandable when viewed out of context.

### Decision

Keep a project-level notebook at `project-notebook.md`.

### Reason

Git records what changed; the project notebook records why significant design decisions were made and which questions were intentionally left open.

### Decision

Use JSON as the canonical machine-readable data format.

### Reason

JSON is broadly supported and makes it practical to develop readers in multiple languages without tying the dataset to Mathematica or any other implementation language.

### Decision

Represent temperature dependence with structured basis terms rather than storing executable equation strings.

### Reason

Structured terms are language-neutral, avoid code evaluation during import, and provide a clean path to expressions involving `T`, `T Log[T]`, and other temperature functions without changing the schema for each new assessment form.

### Decision

Use the Wolfram Language as the initial reference implementation.

### Reason

The project has an existing Mathematica-based teaching workflow, and a clean reference implementation will establish the intended semantics of the JSON representation before additional language readers are developed.

### 2026-08-13 — Freeze the initial information model

### Decision

Separate system-level metadata from phase-level thermodynamic models.

### Reason

A binary system may contain several thermodynamic phases, each with its own Gibbs-energy model. Keeping the phase model as the unit attached to `G(T,X)` avoids ambiguity and avoids duplicating phase-specific information across application code.

### Decision

Give every phase a stable `identifier`, a human-facing `displayName`, and a `displayNameStatus`.

### Reason

The Phase Diagram Tool uses phase names as part of its plotting interface, including its `Names` option. The library should provide a natural default name where one exists, while allowing applications to override it. A best-guess placeholder is acceptable when the literature does not supply a natural name, but the schema must mark that status explicitly.

### Decision

Make composition variables explicit model data rather than assuming that every model uses a single mole fraction `x`.

### Reason

Simple substitutional binaries can use a single component mole fraction, but compounds and solution models may use molality, site fractions, or other coordinates. The schema must accommodate these without redesign.

### Decision

Represent TeX and PDF as generated artifacts attached to each phase model.

### Reason

Some users will want to inspect or teach from the explicit Gibbs-energy equations without downloading or parsing the JSON. Human-readable equation files are therefore first-class deliverables, but they must remain generated from the canonical thermodynamic data rather than becoming a second source of truth.

### Decision

Freeze the initial schema as a design baseline.

### Reason

The schema has now been tested conceptually against simple alloy models, multiple phases, the Phase Diagram Tool interface, and possible future models involving compounds or non-mole-fraction composition coordinates. Future changes should be versioned rather than silently changing field meanings.

### Decision

Store one phase Gibbs-energy model per file under `data/<system>/phases/`, with generated TeX and PDF views under `data/<system>/rendered/`.

### Reason

The phase is the natural unit attached to a `G(T,X)` model in the Phase Diagram Tool. Keeping the machine-readable model and its human-readable renderings in the same system directory makes provenance and discovery straightforward.

### Decision

Use descriptive scientific public names while permitting concise geometric names inside numerical algorithms.

### Reason

The semantic API should make physical meaning clear (for example, `chemicalPotential`), while algorithmic code can use names such as `muLeft`, `muRight`, `leftComposition`, and `rightComposition` when those variables describe tangent geometry rather than chemical identity.

### Decision

Keep the convenient `gMix[system][temperature][composition]` interface while designing the semantic chemical-potential interface around `chemicalPotential[system][component][temperature][composition]`.

### Reason

The former is compact and useful in teaching and numerical work; the latter removes ambiguity when the identity of a component matters.

### Decision

Treat TeX and PDF as user-facing generated views of canonical data, not as separate datasets.

### Reason

A user should be able to inspect the mathematical form of a Gibbs-energy model without downloading or parsing JSON. At the same time, maintaining separate hand-edited equations would create a second source of truth and risk divergence.

### 2026-08-13 — v0.1.0 First Public Preview

### Decision

Release the repository as `v0.1.0`, with the release title **First Public Preview**.

### Reason

The architecture and initial information model are mature enough to invite review, while the scientific dataset and broader reader ecosystem are intentionally incomplete.

### Decision

Adopt semantic versioning for the project.

### Reason

A numerical version makes software and data-model compatibility explicit. Major-version changes indicate incompatible API or information-model changes; minor versions add backward-compatible capabilities or content; patch versions correct errors or documentation without changing the intended interface.

### Decision

Keep a separate `CHANGELOG.md` and `VERSION` file.

### Reason

The changelog records what changed between releases, while the version file provides a simple machine-readable version identifier.

### Decision

State explicitly that OBGEL is curated rather than comprehensive.

### Reason

The project's value comes from provenance, transparency, and pedagogical usefulness rather than the number of systems represented.

### Decision

Adopt the stewardship principle: **Every contribution should make the library more understandable, not merely larger.**

### Reason

The intended audience includes future students, instructors, researchers, and contributors who should be able to understand not only what data are present, but why they were selected and how they were validated.

## Open questions

1. **Community contributions:** Should outside users be invited to submit datasets? If so, should submissions be pull requests, issue-driven requests, or curator-reviewed additions with a defined validation checklist?

2. **Additional language readers:** Should the repository itself maintain readers for Python, Julia, MATLAB, or other languages, or should the JSON format remain language-neutral and readers live in separate projects?

3. **Dissemination:** Should the project eventually be accompanied by a peer-reviewed software/data paper, an arXiv preprint, a GitHub release, or a combination of these?

4. **Licensing:** What licenses should apply separately to source code, curated data, and bibliographic material? This should be decided before the first broader public dataset release.

5. **Initial dataset:** Which small set of systems best demonstrates distinct thermodynamic and pedagogical concepts for the first data release?

6. **Schema evolution:** How should the frozen baseline schema be extended when real published assessments reveal a model class that it does not represent naturally?

## Working principle

Prefer a small number of carefully verified, well-documented examples over a large collection with uncertain provenance or complicated transformations.

The initial curation principle is to ask **why add this system?** before asking whether its parameters can be obtained. Each example should earn its place by illustrating a thermodynamic idea that is useful to students or instructors.
