# 0022 Demarcation of responsibilities between the datatabase and application layers

Date: Unknown

## Status

Accepted

## Context

The project slogan "Foundation for your business" sets a high bar for
the ability to customize LedgerSMB, adapting it to the needs of the
business it desires to be a foundation for.

The software consists -at this time of writing - of several technology
layers each consisting of several modules (from outer to innermost):

 1. The web client
 2. The Perl server component, consisting of e.g.
    1. a document rendering engine (PDF, etc)
    2. a document state management engine (workflow)
    3. a UI renderer
    4. API entry points
 3. The database component, consisting of e.g.
    1. storage engine, with consistency checks (batch, transactions, etc)
    2. query engine in support of UI searches
    3. bank reconciliation procedure

Considering that customization includes businesses developing special purpose
clients to streamline their business processes, it's important to conclude that
although the project maintains a web client, there will likely be more
than one (web) client.

Other areas that businesses likely desire to customize include reporting,
business logic and input/output file processing such as bank statements. One
area where a high level of customization is desired, is the import of bank
statements as well as the bank reconciliation procedure.  As statements for
each bank as well as local payment procedures differ, so will the requirements
for bank reconciliation.  An unsolved problem in the current infrastructure is
running-balance reporting in combination with non-standard (= user selected)
sorting.

Irrespective of the business process to conclude a specific result, it's of
the utmost importance for an accounting and ERP application that the data
it stores is consistent at any point in time.  This point was addressed in
[ADR 0002](./0002-database-consistency-procedural-api.md)

Being restricted to the PL/pgSQL language (see
[ADR 0021](./0021-restricted-list-of-postgresql-extensions.md)) presents a
technical difficulty for developing customizable business logic: the language
is not suitable for developing large-scale applications -- amongst others it
misses the ability to pass around functions and dynamically call those.

Customization at the database level may pose an additional challenge when
creating database upgrade and migration scripts, especially when customizations
mean that function arguments change.

## Decision

The database layer is responsible for storing consistent, referentially sound data;
any logic implemented in the database must be contributing towards that goal.

All business logic must be located in the Perl server layer - that means outside
of the database layer - to allow for flexibility of customization and re-use of
third party libraries.

All queries used in reporting need to be split between re-usable components stored
at the database level for consistency and the Perl application layer for flexibility
in response to changing information requirements.

## Consequences

 1. Stored functions need to be created to save transactions, doing integrity
    checks before or while inserting the data instead of defering this responsibility
    to the application layer (as is currently the case in 'old code')
 2. The folllowing business logic needs to be moved to the application layer:
    1. Bank reconciliation
    2. COGS calculation
    3. Fixed assets depreciation
    4. Year-end closing (i.e. clearing the PnL)
    5. Period closing (i.e. creating a period-end snapshot for PnL, B/S and - in
       the future - also other modules, e.g. AR, AP, inventory, ...)
 3. The queries required for various reports need to be moved to and encapsulated at
    the Perl level, for re-use at that level (instead of being encapsulated in functions
    in the database layer); this includes solutions for user-selected sorting in
    combination with running-balance reporting

## Annotations
