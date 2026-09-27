# 0001: Tech-stack and tool pack names end in -sdlc

**Date:** 2026-09-27 | **Status:** accepted | **Ticket:** none

## Context

A plugin's name is what people see in a list of skills: `aa plugin list`, the agent's skill
picker, and each installed skill's name (`aa-<plugin>-<skill>`). A pack named `dotnet` or
`playwright` reads as a skill for writing .NET code or Playwright tests. These packs are neither:
they say how a stack or a tool carries out the life-cycle steps (build, lint, test tiers, release),
and skills that generate code are deliberately not plugins at all.

## Options

- **A. Tech-stack and tool packs end in `-sdlc`** (`dotnet-sdlc`, `playwright-sdlc`); process
  packs keep a plain name, because a process name already says what it is. Chosen.
- **B. Every pack ends in `-sdlc`.** Uniform, but `change-advisory-sdlc` adds length without
  removing any doubt.
- **C. A prefix, `sdlc-dotnet`.** Sorts the packs together, but a list read by stack or tool is
  easier to scan when the stack or tool comes first.
- **D. Plain names.** Shortest, and exactly the misreading this record exists to prevent.

## Decision

Option A. `src/index.yaml` lists the plugins that exist and the plugins that are planned, and
`scripts/Test-PluginIndex.ps1` fails the build when a tech-stack or tool pack in either list does
not end in `-sdlc`, or when a name appears twice.

## Consequences

- Installed skills read `aa-dotnet-sdlc-<skill>`: longer, and unambiguous.
- A plugin written elsewhere may name itself as it likes; the rule binds this repository.
