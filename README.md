# AA-SDLC plugins

Optional plugins for the [AA-SDLC](https://aasdlc.com) framework. The framework's core describes
the software life cycle and never names a tool; plugins supply the specifics for a tech stack, a
tool, or an extra process step. See [aasdlc.com/plugins.html](https://aasdlc.com/plugins.html)
for what a plugin is.

**Status:** the repository is set up; no plugins are published yet.

## What belongs here

A plugin is one of three kinds:

- **tech-stack**: a language, framework, or platform, such as .NET or Blazor.
- **tool**: a tool the life cycle uses, such as a formatter, a browser-test tool, a load tool,
  or a pipeline system.
- **process**: an extra step or gate, such as a change-advisory review.

Every skill in a plugin attaches to the life cycle: its `SKILL.md` frontmatter names the core
step or process it serves (`aa.attaches_to`) or the core requirement it satisfies
(`aa.satisfies`). A skill that attaches to nothing, such as code generation, script generation,
organisation-wide practice, or media generation, is an ordinary agent skill and does not belong
here. The `aa` command line refuses it.

## Layout

```
src/
  index.yaml        every plugin: name, kind, version, folder, one-line summary
  <name>/
    README.md       what the plugin covers and what it needs
    plugin.yaml     name, version, kind, requirements (the framework's plugin manifest)
    skills/         one folder per skill, each with a SKILL.md
    features/       the plugin's own scenarios, in Gherkin
scripts/            the index validator
tests/              Pester tests
```

The manifest and frontmatter formats are defined once, in the framework's `docs/formats.md`.

## Installing a plugin

From a clone of this repository, inside a repository initialised with `aa init`:

```
aa plugin install <path to this clone>/src/<name>
aa plugin update <name>      # after pulling a newer version
```

Installing by name, without a clone, comes with the framework's release work.

## Working on this repository

```powershell
./initialize.ps1   # install Pester and powershell-yaml if missing
./build.ps1        # validate the index and every plugin folder, assemble .build/plugins
./test.ps1         # run the Pester tests
./pack.ps1         # build, test, and zip each plugin into .dist/
```

To add a plugin, run `/aa-fw-extend` in your agent, or create the folder by hand, add it to
`src/index.yaml`, and run `./build.ps1`.

## Licence

[Functional Source License 1.1, Apache 2.0 future licence](LICENSE.md), as the framework.
