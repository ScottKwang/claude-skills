# Split PR

Break up a large pull request (or local branch) into multiple smaller, logically independent pull requests that are easier to review.

## Usage

- `/split-pr <PR-URL-or-number>` - Split an existing GitHub PR
- `/split-pr` - Split the current branch's uncommitted or committed changes vs main

## Arguments
$ARGUMENTS

---

## Instructions

You are splitting a large set of changes into smaller, reviewable pull requests. The goal is to make code review faster and less error-prone by isolating logically independent changes into their own PRs.

### Step 1: Identify the changes

Determine what you're working with based on the user's input:

**If given a PR URL or number:**
1. Fetch the PR metadata: `gh pr view <number> --json title,body,baseRefName,headRefName,number,files`
2. Check out the PR branch locally: `gh pr checkout <number>`
3. Get the full diff against the base: `git diff <base>..HEAD`

**If no PR specified (local branch):**
1. Identify the current branch and its divergence from main: `git merge-base main HEAD`
2. Get the full diff: `git diff $(git merge-base main HEAD)..HEAD`
3. Get the commit log: `git log --oneline $(git merge-base main HEAD)..HEAD`

Read and understand every changed file. Don't just look at the diff — read surrounding context so you understand what each change does and why it exists.

### Step 2: Analyze and group changes

Study the changes and identify logical units. A logical unit is a set of changes that:
- Serve a single purpose (e.g., "add validation to user input", "refactor database queries", "update API response format")
- Can be understood in isolation by a reviewer
- Would pass tests independently (or at least not break the build)

Common split patterns:
- **Refactor + feature**: Extract the refactoring (renames, restructuring, moving code) into its own PR, then the feature builds on top
- **Infrastructure + usage**: New utility/helper/config in one PR, code that uses it in another
- **Independent features**: Changes to unrelated parts of the codebase that were bundled together
- **Tests + implementation**: Sometimes test additions can land separately, especially if they test existing behavior
- **Type/interface changes + implementation**: Type definitions or interface changes first, then the code that implements them

It's OK to split a single file's changes across PRs if the changes within that file are logically independent (e.g., one function was refactored and another was added).

Think carefully about what a reviewer needs to see together to understand the intent. Don't split so aggressively that each PR becomes meaningless — a PR that only renames one variable isn't worth the overhead. Aim for 2-4 PRs in most cases; more if the original is truly massive.

### Step 3: Determine dependencies

For each logical group, determine whether it depends on another group:
- If group B modifies code that group A introduces, B depends on A
- If group B imports a type/function that group A adds, B depends on A
- If two groups touch entirely different files and concepts, they're independent

Build a dependency graph. The result is either:
- **Independent PRs**: All target main/the original base branch
- **Stacked PRs**: PR 2 branches off PR 1's branch, PR 3 off PR 2, etc.
- **A mix**: Some independent, some stacked

### Step 4: Present the plan

Before creating any branches or PRs, present the decomposition to the user:

```
Here's how I'd split this:

PR 1: "Refactor UserService to extract validation logic"
  - src/services/user-service.ts (extract validateEmail, validatePhone)
  - src/utils/validation.ts (new file)
  - tests/utils/validation.test.ts (new file)
  Targets: main

PR 2: "Add phone number verification endpoint" (depends on PR 1)
  - src/routes/verification.ts (new file)
  - src/services/user-service.ts (add verifyPhone method)
  - tests/routes/verification.test.ts (new file)
  Targets: PR 1's branch

PR 3: "Update API docs for user endpoints"
  - docs/api/users.md
  Targets: main (independent)
```

Ask the user: "Does this split look right? Want me to adjust anything before I create the branches?"

Wait for confirmation before proceeding.

### Step 5: Create the branches and PRs

For each PR in dependency order:

1. **Create a new branch** from the appropriate base:
   ```
   git checkout <base-branch>
   git checkout -b <descriptive-branch-name>
   ```
   Use clear branch names like `refactor/extract-validation`, `feat/phone-verification`, etc.

2. **Cherry-pick or apply the relevant changes.** This is the most delicate part. Depending on the original commit structure:
   - If the original has clean, logical commits that map to your groups: `git cherry-pick <commits>`
   - If changes are interleaved across commits: check out specific files or hunks from the original branch, then commit them:
     ```
     git checkout <original-branch> -- <file1> <file2>
     ```
   - For partial file changes (splitting one file across PRs): manually apply the relevant hunks using the Edit tool

3. **Verify the branch builds/works:**
   - Run any available build commands or type checks
   - If tests exist, verify they pass (at minimum, verify no syntax errors)
   - If a change doesn't compile alone, you may need to include a stub or minimal dependency — note this in the PR description

4. **Push and create the PR:**
   ```
   git push -u origin <branch-name>
   gh pr create --base <target-branch> --title "<title>" --body "<body>"
   ```

   Each PR description should include:
   - A summary of what this slice does and why it's a separate PR
   - If part of a stack: "This is part N of a series splitting #<original-PR>. Depends on #<prev-PR>."
   - If independent: "This is part of splitting #<original-PR> and can be reviewed independently."
   - The key changes and what to focus on during review

### Step 6: Handle the original

Ask the user what they'd like to do with the original PR/branch:
- **Close it** with a comment linking to the new PRs
- **Leave it open** as a tracking reference
- **Convert it to a draft** with links to the split PRs

If the user chose to close it:
```
gh pr comment <number> --body "Split into smaller PRs for easier review: #X, #Y, #Z"
gh pr close <number>
```

### Edge cases and guardrails

- **Merge conflicts between split PRs**: If stacked PRs would conflict with each other, warn the user and suggest an alternative grouping
- **Very large PRs (50+ files)**: Group by directory/module first to get a rough split, then refine within each group
- **PRs with migration files**: Database migrations almost always need to stay together and go in the first PR of a stack
- **Config file changes**: Changes to shared config (package.json, tsconfig, CI configs) should go in whichever PR actually needs them; if multiple do, put them in the earliest dependency
- **Don't lose changes**: After creating all split PRs, verify that the union of all changes matches the original diff. Use `git diff` to compare. If anything is missing, flag it immediately.
