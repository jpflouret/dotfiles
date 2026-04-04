# Global Claude Code Instructions

## Text Encoding

All code and comments must use ASCII characters only. Do not use Unicode punctuation such as em-dashes , smart quotes ("\u201c\u201d"),
ellipsis (\u2026), etc. Use plain ASCII equivalents (e.g. "-", "--", "...", "\""). Avoid em-dashes or fake em-dashes (--). Use full sentences instead.

## Git

- Never add Co-Authored-By trailers to commit messages
- Commit messages should be brief and not describe every detail
- Prefer single line commit messages
- Prefer -m over heredoc for commit messages
- Never use 'git -C' or 'cd /path && git' when already in the repo working directory. Only use these when targeting a different repository.
- Always run git add and git commit as separate commands, never chained together

## Kubernetes

- Always put --context at the end of kubectl and flux commands so permissions across clusters work.

## Bug Fixes

- If a project has test infrastructure, write a failing test that reproduces the bug before writing the fix.
- Verify the test fails with the old code, then apply the fix and confirm it passes.
