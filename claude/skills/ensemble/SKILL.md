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
- Codex: `... | codex exec "<brief>"`  — hostile critic
- AGY:   `... | agy -p "<brief>"`      — divergent + large-context

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
   `.ensemble/tests/` directory and print `NO_FINDINGS` if clean — then launch:
   ```
   git diff <base>... | codex exec "$(cat /tmp/ensemble-critic-brief.md)"
   git diff <base>... | agy -p     "$(cat /tmp/ensemble-critic-brief.md)"
   ```
   The peers are separate processes the hook does not govern, so they can author tests
   there. If AGY won't author files in this headless setup, capture its findings and have
   **Codex** encode them — never encode them yourself; you are the fixer.
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

   <target> | agy -p "Independently evaluate this <artifact>. Do NOT line-edit it.
   (1) the strongest genuinely DIFFERENT approach and its tradeoffs; (2) what a strong
   version would include that THIS is MISSING; (3) what it gets right that's worth
   protecting. Specific to THIS document. Numbered list." > .ensemble/review/<slug>-agy.md
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

Peers are *instructed* to write only under `.ensemble/tests/`, but nothing forces it —
they're separate processes the hook doesn't govern. Branch A step 3 (full-suite re-run)
mitigates: a peer that secretly patched app code wouldn't leave its own test red. Hardening
path (future): run each peer under a sandbox scoped to the review dir (`codex --sandbox`,
`agy --sandbox`).
