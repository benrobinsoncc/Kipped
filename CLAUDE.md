# Claude Instructions for Kipped

## Core Development Principles

### 🛠️ Work with Existing Code - NO SHORTCUTS
- **NEVER create mock data or simplified components** unless explicitly requested
- **NEVER replace complex components with simplified versions** - fix the actual problem
- **ALWAYS find and fix the root cause** instead of creating workarounds
- **When debugging, fix the existing implementation - don't start over**
- **ALWAYS check Apple's latest SwiftUI documentation** before making changes

### ✅ Code Validation & Testing
- **Ensure Xcode shows no errors or warnings** before considering changes complete
- Fix all compiler errors and warnings immediately
- Test on simulator/device after changes - SwiftUI preview isn't enough
- Check Xcode console for runtime warnings (purple warnings about view updates)
- Use explicit types where it improves clarity

### 🧩 Structured Development Process
- Break complex requests into single, sequential changes
- Make one change at a time and wait for approval
- Number each step (e.g., "Change 1 of 4 complete") for progress tracking
- After each change:
  - Test the specific change
  - Verify existing features still work
  - Check for new warnings/errors
  - Ask "Should I proceed with the next change?"
- If a step becomes problematic, explain why and suggest alternatives

### 💬 Clear Communication
- Lead with the key point, then provide supporting details
- Use design terminology (components, styling, layout)
- Describe visual outcomes ("This will turn the button blue")
- Specify which file and what changes are being made
- Avoid technical jargon - use clear, direct language

### ❓ Clarification Before Action
When requirements are unclear, ask:
- What exactly needs changing and what's the desired result?
- Which specific element, file, or behavior?
- Is this about layout, styling, functionality, or data?
- Would a screenshot help clarify the issue?

**Don't guess - clarity upfront prevents cascading bugs and wasted effort.**