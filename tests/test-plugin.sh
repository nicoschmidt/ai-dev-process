#!/usr/bin/env bash
# Structural checks that keep the parts of this repository in step with each
# other: the plugin and the marketplace, the version in three places, the
# skills' frontmatter, the managed-file headers, the imports in CLAUDE.md, the
# CI gates, and the rule that nothing project-specific enters the kit.
#
#   bash tests/test-plugin.sh
#
# Needs python3 (standard library only). `claude plugin validate .` is the
# fuller check when Claude Code is installed; this one runs in CI without it.

set -uo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

python3 - <<'PY'
import json, pathlib, re, sys

root = pathlib.Path(".")
failures = 0

def check(description, ok, detail=""):
    global failures
    if ok:
        print(f"  ok    {description}")
    else:
        failures += 1
        print(f"  FAIL  {description}")
        if detail:
            print(f"        {detail}")

print("plugin and marketplace")
market = json.loads((root / ".claude-plugin/marketplace.json").read_text())
entries = market.get("plugins", [])
check("marketplace has name and owner", bool(market.get("name")) and bool(market.get("owner", {}).get("name")))
check("marketplace lists one plugin", len(entries) == 1, f"found {len(entries)}")
entry = entries[0] if entries else {}
plugin_dir = root / entry.get("source", "")
manifest = json.loads((plugin_dir / ".claude-plugin/plugin.json").read_text())
check("entry name equals manifest name", entry.get("name") == manifest.get("name"),
      f"{entry.get('name')} != {manifest.get('name')}")
check("source has no ..", ".." not in entry.get("source", ""))

print("one version in three places")
version = (root / "VERSION").read_text().strip()
check("plugin.json version equals VERSION", manifest.get("version") == version,
      f"{manifest.get('version')} != {version}")
changelog = (root / "CHANGELOG.md").read_text()
check("CHANGELOG has a section for VERSION", re.search(rf"^## {re.escape(version)} ", changelog, re.M) is not None)
check("CHANGELOG has an Unreleased section", "## Unreleased" in changelog)

print("skills")
skills = sorted(p for p in (plugin_dir / "skills").iterdir() if p.is_dir())
check("there are skills", len(skills) > 0)
names = set()
for skill in skills:
    text = (skill / "SKILL.md").read_text() if (skill / "SKILL.md").exists() else ""
    m = re.match(r"^---\n(.*?)\n---\n", text, re.S)
    front = dict(re.findall(r"^(\w[\w-]*):\s*(.*)$", m.group(1), re.M)) if m else {}
    names.add(skill.name)
    check(f"{skill.name}: name matches its directory", front.get("name") == skill.name, front.get("name", "no frontmatter"))
    desc = front.get("description", "")
    check(f"{skill.name}: description present and under 1024 characters", 0 < len(desc) <= 1024, f"{len(desc)} characters")
    check(f"{skill.name}: description has no angle brackets", "<" not in desc and ">" not in desc)

print("every /ai-dev-process:<skill> mentioned exists")
mentioned = set()
for path in list(root.glob("**/*.md")) + list(root.glob("kit/**/*.md")):
    if ".git" in path.parts:
        continue
    mentioned |= set(re.findall(r"/ai-dev-process:([a-z-]+)", path.read_text()))
missing = sorted(mentioned - names)
check("no reference to a missing skill", not missing, ", ".join(missing))

print("managed files")
rules = sorted((root / "kit/common/.claude/rules/process").glob("*.md"))
check("there are rules", len(rules) > 0)
header = "<!-- Managed by ai-dev-process."
for rule in rules + [root / "kit/common/docs/process.md"]:
    check(f"{rule}: starts with the managed header", rule.read_text().startswith(header))
claude = (root / "CLAUDE.md").read_text()
for rule in rules:
    check(f"CLAUDE.md imports {rule.name}", f"@{rule.as_posix()}" in claude)

print("nothing project-specific in what projects receive")
deny = re.compile(r"adventure|dungeon|combat|encounter|hit points|\bD&D\b", re.I)
hits = []
for base in ("kit", "templates", "plugins"):
    for path in (root / base).rglob("*"):
        if path.is_file():
            for n, line in enumerate(path.read_text(errors="replace").splitlines(), 1):
                if deny.search(line):
                    hits.append(f"{path}:{n}")
check("no domain words from the project the kit came from", not hits, "; ".join(hits[:5]))

print("kit and templates by role")
# Tracked files only, as install.sh reads them: a .DS_Store is not shipped.
import subprocess
tracked = subprocess.run(["git", "ls-files", "kit", "templates"], capture_output=True, text=True, check=True).stdout.split()
for sub in ("kit/common", "kit/home", "templates/all", "templates/home", "templates/member"):
    check(f"{sub} has files", any(t.startswith(sub + "/") for t in tracked))
roles = {"kit": ("common", "home"), "templates": ("all", "home", "member")}
stray = [t for t in tracked if t.split("/")[1] not in roles[t.split("/")[0]]]
check("nothing in kit/ or templates/ outside the role directories", not stray, ", ".join(stray))
def paths(sub):
    return {t[len(sub) + 1:] for t in tracked if t.startswith(sub + "/")}
for role, parts in {"single/home": ("kit/common", "kit/home", "templates/all", "templates/home"),
                    "member": ("kit/common", "templates/all", "templates/member")}.items():
    seen, twice = set(), set()
    for part in parts:
        twice |= seen & paths(part)
        seen |= paths(part)
    check(f"role {role}: no path shipped twice", not twice, ", ".join(sorted(twice)))

print("CI gates wait for every job")
for workflow in (root / ".github/workflows/ci.yml", root / "templates/all/.github/workflows/ci.yml"):
    text = workflow.read_text()
    jobs_block = text.split("\njobs:\n", 1)[1]
    jobs = re.findall(r"^  ([a-z][a-z0-9-]*):\s*$", jobs_block, re.M)
    gate = re.search(r"^  ci-passed:\n(.*?)(?=^  [a-z]|\Z)", jobs_block, re.S | re.M)
    needs = re.search(r"needs:\s*\[([^\]]*)\]", gate.group(1)).group(1) if gate else ""
    needs = {n.strip() for n in needs.split(",") if n.strip()}
    others = set(jobs) - {"ci-passed"}
    check(f"{workflow}: ci-passed needs every other job", others == needs, f"jobs {sorted(others)}, needs {sorted(needs)}")
    check(f"{workflow}: ci-passed runs always()", gate is not None and "if: always()" in gate.group(1))

print()
if failures:
    print(f"{failures} check(s) failed")
    sys.exit(1)
print("all checks passed")
PY
