# Claude Instructions for Kipped

### Critical Rules - DO NOT VIOLATE
- **NEVER create mock data or simplified components** unless explicitly told to do so
- **NEVER replace existing complex components with simplified versions** - always fix the actual problem
- **ALWAYS work with the existing codebase** - do not create new simplified alternatives
- **ALWAYS find and fix the root cause** of issues instead of creating workarounds
- When debugging issues, focus on fixing the existing implementation, not replacing it
- When something doesn't work, debug and fix it - don't start over with a simple version
- **ALWAYS check Apple's latest SwiftUI documentation** before making changes - APIs change between iOS versions

### Swift and Xcode Validation
- **ALWAYS use explicit types** where it improves clarity (though Swift's type inference is intentional)
- **ALWAYS ensure Xcode shows no errors or warnings** before considering any code changes complete
- Fix all compiler errors and warnings immediately - don't leave them for the user to fix
- When making changes to multiple files, ensure each builds cleanly
- **ALWAYS test on simulator/device** after changes - SwiftUI preview isn't enough
- Check for runtime warnings in Xcode console (purple warnings about view updates, etc.)