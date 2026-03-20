# Global Claude Code Instructions

## Text Encoding

All code and comments must use ASCII characters only. Do not use Unicode punctuation such as em-dashes , smart quotes ("\u201c\u201d"),
ellipsis (\u2026), etc. Use plain ASCII equivalents (e.g. "-", "--", "...", "\""). Avoid em-dashes or fake em-dashes (--). Use full sentences instead.

## Git

- Never add Co-Authored-By trailers to commit messages
- Commit messages should be brief and not describe every detail
- Prefer single line commit messages
- Prefer -m over heredoc for commit messages
- Avoid using 'git -C' or 'cd /path && git' when it isn't necessary
- Always run git add and git commit as separate commands, never chained together
