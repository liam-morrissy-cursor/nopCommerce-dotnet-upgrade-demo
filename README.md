# nopCommerce .NET Upgrade Demo

A reusable demo environment for showing Cursor performing a **large-scale .NET
upgrade/migration**: [nopCommerce](https://github.com/nopCommerce/nopCommerce)
pinned to **4.50.4**, the last release targeting **.NET 6** (end-of-life since
November 2024). The demo is to upgrade it to a modern .NET (8/9/10) with
Cursor — then reset and do it again for the next customer.

## Branch layout

| Branch | Contents | Reset behavior |
|---|---|---|
| `demo` | nopCommerce 4.50.4 (.NET 6) — **run the demo here** | Force-reset to the baseline |
| `net6-baseline` | Pristine copy of upstream `release-4.50.4` | Re-mirrored from upstream |
| `main` | This README + demo tooling only (no app code) | Never touched by resets |

## Running the demo

```bash
git clone https://github.com/liam-morrissy-cursor/nopCommerce-dotnet-upgrade-demo.git
cd nopCommerce-dotnet-upgrade-demo
git checkout demo
```

Open in Cursor and drive the migration from there (e.g. "Upgrade this solution
from .NET 6 to .NET 9, including all csproj target frameworks, NuGet packages,
and breaking API changes"). Every `.csproj` under `src/` targets `net6.0`, and
package references are 2022-era — plenty of surface area for a large-scale,
multi-project migration story.

## Resetting the demo

Any of these restores `demo` (and `net6-baseline`) to pristine .NET 6 state:

1. **The script** (requires the [GitHub CLI](https://cli.github.com/), authenticated):

   ```bash
   ./demo-tools/reset-demo.sh            # reset demo + baseline branches
   ./demo-tools/reset-demo.sh --prune    # also delete leftover demo branches
   ```

   Run it from inside a local clone and it will hard-reset your local `demo`
   branch too. The script lives on `main`, so grab it from there (or run the
   one-liner below from anywhere).

2. **One-liner**:

   ```bash
   gh workflow run reset-demo.yml -R liam-morrissy-cursor/nopCommerce-dotnet-upgrade-demo
   ```

3. **No CLI**: edit `demo-tools/reset-trigger` on `main` in the GitHub web UI
   (any change), or run the "Reset upgrade demo" workflow from the Actions tab.

The reset works by re-cloning upstream nopCommerce at `release-4.50.4` on a
GitHub Actions runner and force-pushing it over `demo` and `net6-baseline`, so
it always returns to a bit-identical baseline no matter what happened during
the demo.

## Notes

- This repo is a mirror rather than a GitHub-native fork: the account's fork
  slot for nopCommerce is already used by
  [`liam-morrissy-cursor/nopCommerce`](https://github.com/liam-morrissy-cursor/nopCommerce),
  and keeping the demo isolated from that fork is safer anyway.
- To base the demo on an even older stack, pass `--tag` to the reset script
  (e.g. `--tag release-4.40.4` for .NET 5, `--tag release-4.30` for
  .NET Core 3.1). The branch name `net6-baseline` stays the same.
- Building the baseline locally requires the
  [.NET 6 SDK](https://dotnet.microsoft.com/download/dotnet/6.0).
