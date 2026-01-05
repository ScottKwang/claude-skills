# Spec Generator

Deep-dive specification interviewer. Reads existing spec and conducts thorough interview about non-obvious aspects of the project.

## Usage

- `/spec-generator` - Start spec interview for current project
- `/spec-generator <path>` - Interview based on specific spec file

## Arguments
$ARGUMENTS

---

## Instructions

### Step 1: Find or Create Spec

1. Look for existing spec files:
   - `SPEC.md`
   - `spec.md`
   - `.taskmaster/docs/prd.md`
   - `docs/spec.md`
   - `PRD.md`

2. If found, read and analyze it
3. If not found, ask user to describe the project briefly

### Step 2: Analyze for Gaps

Review the spec for:

1. **Missing Edge Cases**
   - What happens when X fails?
   - How to handle empty states?
   - Rate limiting? Timeouts?

2. **Ambiguous Requirements**
   - "Fast" - how fast exactly?
   - "User-friendly" - what does that mean?
   - "Scalable" - to what level?

3. **Conflicting Requirements**
   - Performance vs. features
   - Security vs. convenience
   - Cost vs. quality

4. **Missing Decisions**
   - Authentication method?
   - Data storage approach?
   - Error handling strategy?

### Step 3: Conduct Interview

Use AskUserQuestion to ask 3-4 questions at a time, grouped by topic.

**Question Categories:**

1. **User Experience**
   - Who is the primary user?
   - What's the most critical user flow?
   - How should errors be presented?

2. **Technical Decisions**
   - What's the preferred tech stack?
   - Any existing infrastructure to integrate with?
   - Performance requirements?

3. **Business Logic**
   - What happens in edge cases?
   - Priority order when conflicts arise?
   - What's MVP vs. nice-to-have?

4. **Operations**
   - How will this be deployed?
   - Monitoring requirements?
   - Backup/recovery needs?

### Step 4: Document Decisions

After each question batch, append answers to a decisions log:

```markdown
## Spec Interview Decisions

### [Category]

**Q:** [Question asked]
**A:** [User's answer]
**Rationale:** [Why this matters]
```

### Step 5: Generate Updated Spec

After interview is complete:

1. Create or update `SPEC.md` with:
   - Original requirements
   - All interview decisions
   - Appendix with decision rationale

2. Format:
```markdown
# Project Specification

## Overview
[High-level description]

## Requirements
[Detailed requirements]

## Technical Decisions
[Decisions made during interview]

## Edge Cases
[How edge cases are handled]

## Appendix: Decision Log
[Full interview Q&A]
```

---

## Interview Best Practices

1. **Ask non-obvious questions** - Probe edge cases, conflicts, tradeoffs
2. **Batch related questions** - Group 3-4 questions per AskUserQuestion call
3. **Use multi-select sparingly** - Most decisions should be single-choice
4. **Capture rationale** - The "why" matters as much as the "what"
5. **Don't assume** - When uncertain, ask

## Example Questions

- "When a user's session expires mid-action, should we save their progress or require them to start over?"
- "If the external API is down, should we show cached data, an error, or a degraded experience?"
- "What's the maximum acceptable latency for the main user action?"
- "Should failed operations be retried automatically? If so, how many times?"

## Notes

- Save interview progress to `.claude/spec-interview.md` in case of interruption
- Always summarize decisions at the end
- Offer to generate task list from final spec
