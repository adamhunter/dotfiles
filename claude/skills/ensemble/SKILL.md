---
name: ensemble
description: Use when the user asks to review a PR, merge request, diff, code change, plan, RFC, design doc, architecture, spec, or proposal — including "review this", "peer review", "get a second opinion", "have the other models look at this", or "what do Codex and Gemini think". Use whenever a review is requested instead of reviewing single-handedly.
---

# Ensemble — Multi-Model Review

## Overview

You coordinate a review by two **foreign-model peers** — Codex (OpenAI) and AGY
(Antigravity / Gemini) — instead of reviewing alone. The value comes entirely from
their being *different model families* than you: they catch what same-model self-review
structurally cannot. You orchestrate; **in neither branch are you the one who decides
what is true.**

**Violating the letter of these rules is violating the spirit of them.** If you catch
yourself wanting to summarize the artifact for the peers, reconcile their disagreement,
or run just the new test — stop. Each silently collapses the mechanism into a single
model talking to itself.

Peers (both are agentic CLIs; piped stdin is appended to the prompt):
- Codex: `... | codex exec "<brief>"`  — hostile critic. Defaults to a **read-only**
  sandbox; Branch A test-authoring needs `--sandbox workspace-write` (see Branch A).
- AGY:   isolated — `<artifact> | ( cd "$(mktemp -d)" && agy --sandbox -p "<brief>" )`
  — divergent + large-context. The wrapper is mandatory; see **AGY SAFETY**.

**AGY SAFETY — non-negotiable.** AGY in `-p` mode runs its file-edit tool against its working
directory even when told not to, and `--sandbox` does NOT stop that — it blocks only terminal
commands (verified 2026-06-15). So **never run AGY in a repo you care about.** Always isolate
it: run from a throwaway scratch cwd, feed the artifact via **stdin**, and consume only its
**stdout**, so AGY has no real files to touch and any writes land in the junk dir:
```
scratch=$(mktemp -d); <artifact> | ( cd "$scratch" && agy --sandbox -p "<brief>" ) > <out>; rm -rf "$scratch"
```
Verified: a sentinel repo survived even an adversarial isolated AGY run. This is
workflow-isolation, not an OS sandbox — never hand AGY real absolute paths. Can't isolate it?
Drop AGY and go codex-only.

Working dirs are **per-repo, never global** — created in the current working directory of
whatever repo you are reviewing in, all under a single `.ensemble/` dir:
- `.ensemble/tests/` — Branch A critic-authored failing tests (you are **hard-locked** out).
- `.ensemble/review/` — Branch B raw peer outputs + your digest (you write here).
`.ensemble/` is already in the global gitignore, so nothing here is ever committed.

Operational notes:
- A `codex` call with no pipe and non-TTY stdin hangs on EOF. If you ever call it
  without piping, append `< /dev/null`.
- Cap large inputs before piping: `head -c 50000`. Past the context window you get
  *silent* truncation — a confidently incomplete review with no error.

## Step 0 — Resolve the target (raw, never paraphrased)

From the user's request, determine exactly what is under review: a file path, a
branch/PR diff (`git diff <base>...`), pasted text, or a URL. State what you resolved in
one line. **Pipe the real thing to the peers — never your summary or reframing of it.**
The moment you narrate the artifact to your own reviewer, you re-correlate the input and
the entire point is lost.

## Step 0.5 — Egress gate (before any peer call)

Both peers send artifact text to **OpenAI and Google**. Fine for ordinary work,
unacceptable for regulated artifacts (FedRAMP-Moderate / government / export- or
compliance-controlled). If there is any doubt this artifact may leave for third-party
APIs, **ask the human before piping it** — not after. The human decides the boundary.

## Step 1 — Classify the artifact

- **FALSIFIABLE** — code, a diff, a PR. A test can settle whether a finding is real →
  **Branch A**.
- **JUDGMENT** — a plan, RFC, design, architecture, prose. No test can settle it →
  **Branch B**.
- Genuinely both (a PR that also proposes a design)? Run **both** branches.
- Genuinely ambiguous? Ask one question. Otherwise state the class and proceed.

---

## Branch A — FALSIFIABLE (you are the FIXER; the test suite is the ARBITER)

You have an incentive to cheat — to weaken the critic's test until it goes green. You are
**hard-blocked**: a PreToolUse hook denies any tool call touching `.ensemble/tests/` via
Edit/Write/MultiEdit *and* via Bash (`sed`, `cat >`, `mv`, `rm`), and it also blocks
wholesale ops on the parent (`rm -rf .ensemble`, `mv .ensemble …`) so you can't nuke the
tests by deleting their parent. Do not try to route around it. The block also trips on any
Bash command whose *text* names `.ensemble/tests` — step 2 shows how to launch the critics
anyway.

1. Capture the artifact: `git diff <base>...` (or the file/code in question).
2. Run **both** critics on the **real** artifact. Each writes runnable, framework-native
   tests that **FAIL iff a defect exists**, into `.ensemble/tests/` ONLY, for falsifiable
   defects only (logic, edge cases, races, crashes, reproducible security). No
   stylistic/design tests. A peer that finds nothing prints `NO_FINDINGS` and writes nothing.

   Because the lockout blocks any Bash command that *names* the protected dir, deliver the
   brief through a file (create it with the **Write tool**, not a Bash heredoc) so your
   launch command stays clean. Put the failing-test brief in e.g.
   `/tmp/ensemble-critic-brief.md` — instruct the peer to write only under the
   `.ensemble/tests/` directory and print `NO_FINDINGS` if clean.

   **Codex authors the tests** — it needs write access (its default sandbox is read-only),
   so run it with `workspace-write`. It is a separate process the hook doesn't govern, so it
   can write into `.ensemble/tests/`:
   ```
   git diff <base>... | codex exec --sandbox workspace-write "$(cat /tmp/ensemble-critic-brief.md)"
   ```
   **AGY contributes findings only — it NEVER authors files here.** Run it sandboxed and ask
   only for a description of defects, then have **Codex** encode AGY's findings into tests on
   a follow-up codex call. Never encode them yourself; you are the fixer.
   ```
   git diff <base>... | ( cd "$(mktemp -d)" && agy --sandbox -p "List falsifiable defects in this diff (logic, edge cases, races, crashes, reproducible security). One line each. Do NOT edit files or run commands." )
   ```
3. Run the **FULL** suite (e.g. `pytest`, `npm test` — these auto-discover the
   `.ensemble/tests/` tests; do not name the dir on the command line, or the hook blocks
   your command). A failing critic test = confirmed defect. Passing = dismissed silently.
   You do not judge validity; red/green does. **Never run only the new test** — the full
   suite catches a fix that satisfies one repro while leaving the bug class, and catches a
   peer that edited app code.
4. Fix **application code only** until green. You may not edit, move, delete, weaken, or
   route around anything in `.ensemble/tests/`.
5. Re-run the full suite; repeat 4–5 up to **3 rounds**.
6. Report each fixed defect named by its proving test. Anything still red after 3 rounds
   → **EXCEPTION**: stop and surface it to the human. **Never force it green.** State that
   only falsifiable defects were in scope.

## Branch B — JUDGMENT (you are a FAITHFUL AGGREGATOR; the human is the ARBITER)

No oracle exists, so the human stays in the loop — but you shrink what they read without
deciding for them. There's no test to cheat here, so the rule is: **preserve everything,
adjudicate nothing.**

1. Create the review dir: `mkdir -p .ensemble/review` (always use the `.ensemble/review`
   subpath — the hook guards the bare `.ensemble` parent). Fan out to both peers
   **independently**, raw, with different lenses. **Never show one peer the other's
   output** — that manufactures correlation where you need independence. Save each raw
   output under `.ensemble/review/` so the human can audit your digest against source:
   ```
   <target> | codex exec "You are a hostile reviewer of this <artifact>. Attack it:
   unstated assumptions, failure modes, what breaks at scale/under load, security and
   compliance gaps, operational risk, where it goes wrong in production. Specific to THIS
   document. No praise, no restating it. Numbered list; each item: severity
   (high/med/low) + one line of why." > .ensemble/review/<slug>-codex.md

   scratch=$(mktemp -d); <target> | ( cd "$scratch" && agy --sandbox -p "Independently evaluate this <artifact>. Do NOT line-edit it.
   (1) the strongest genuinely DIFFERENT approach and its tradeoffs; (2) what a strong
   version would include that THIS is MISSING; (3) what it gets right that's worth
   protecting. Specific to THIS document. Numbered list." ) > .ensemble/review/<slug>-agy.md; rm -rf "$scratch"
   ```
2. Build a digest by **organizing** — never editing or dismissing — the two raw outputs
   (write it to `.ensemble/review/<slug>-digest.md`):
   - **CONVERGENT** — concerns both raised independently. Rank first; two decorrelated
     models landing on the same thing is the strongest signal short of a test.
   - **SINGLE-SOURCE** — raised by only one; label which peer.
   - **CONTESTED** — where they disagree or contradict each other; flag for the human.
   Preserve each finding's substance and severity. **Drop nothing. Never declare a concern
   invalid — that's the human's call.** Link both raw files.
3. **Stop. The human adjudicates.** Do not "resolve" the review yourself.

## Red flags — STOP if you catch yourself

- "I'll just summarize the diff for the peers" → No. Pipe the raw artifact (Asymmetry 1).
- "Both peers agree, so it's settled" (Branch B) → No. Convergence is signal, not a
  verdict; the human decides.
- "This peer finding is obviously wrong, I'll drop it" (Branch B) → No. Organize, don't
  adjudicate.
- "I'll show Codex's findings to AGY for consensus" → No. Independent fan-out only.
- "The new test passes, I'll skip the full suite" (Branch A) → No. Always the full suite.
- "Edit on the `.ensemble/tests/` file is blocked, I'll `sed`/`cat >`/`mv`/`rm` it — or
  `rm -rf .ensemble`" → No. The hook blocks Bash and the parent dir too; that's cheating
  the oracle.
- "Still red after 3 rounds, I'll just make it pass" → No. That's an EXCEPTION for the human.

## v1 scope & roadmap (why we stop at disagreement)

This is the *ensemble cast* stage by design: distinct independent voices surfaced in
parallel, **not blended**. Branch B deliberately does not reconcile judgment findings yet,
because reconciling before the base signal is validated is exactly how you get consensus
laundering — higher confidence, no higher accuracy. First dial in decorrelated fan-out and
convergence detection; only then add aggregation. The intended evolution toward *true
ensemble* is a **third, independent arbiter** that synthesizes the `CONTESTED` bucket only
— never the two original peers debating each other into agreement (that reintroduces
anchoring/sycophancy). **Do not build that until explicitly asked.**

## Known trust gap (v1)

Codex authors tests under `--sandbox workspace-write`; it is *instructed* to write only
under `.ensemble/tests/`, but `workspace-write` doesn't force that — it could touch app
code (`danger-full-access` is never used). Branch A step 3 (full-suite re-run) mitigates: a
peer that secretly patched app code wouldn't leave its own test red. AGY is **isolated** (run
from a throwaway cwd with the artifact via stdin, stdout only) and findings-only, because
`--sandbox` does NOT stop its file-edit tool (verified) — isolation, not the flag, is what
contains it, and only for this review workflow (it is not an OS sandbox). Hardening path: an
OS-level sandbox (`sandbox-exec` / container) for true containment of both peers, and scoping
codex's writes to `.ensemble/tests/` specifically (`--cd` + writable-dir scoping).
