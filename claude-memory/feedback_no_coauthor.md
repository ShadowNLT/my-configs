---
name: feedback_no_coauthor
description: Never add Claude as co-author in git commits
metadata: 
  node_type: memory
  type: feedback
  originSessionId: 7b4f1c64-6c46-4e77-a509-c6848f94a6db
---

Never append a `Co-Authored-By: Claude` trailer to git commits.

**Why:** User preference — they don't want AI attribution in their commit history.

**How to apply:** Omit the Co-Authored-By line entirely from every commit message.
