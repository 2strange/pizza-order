# Workflow

This repository was built by one developer directing a small team of AI agents
(Claude and Codex). The agents write code and tests; the developer sets direction,
reviews every change, decides every trade-off and owns the result.

- Direction and review: the developer
- Domain model and specs: one agent, reviewed by a second one before merge
- Frontend components: one agent, reviewed independently
- Design: one agent, briefed with the domain first, visuals second

Nothing lands on `main` without a green CI run and a human review.
