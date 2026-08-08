# AI Agents Configuration

This file configures how AI assistants interact with this framework-driven repository.

## 🚨 CONTEXT ENGINE (SINGLE SOURCE OF TRUTH)
**DO NOT hardcode a static loading pipeline.**
**DO NOT read raw JSON files from `.ai/` directly.**
The architecture uses a dynamic Context Engine located at `tools/context/context_engine.dart`.
To acquire context, the AI MUST use this engine (or execute it via a script/tool) to selectively load ONLY the necessary context based on the task (Widget, Cubit, Feature, etc.).
Philosophy: *Analyze only what is necessary. Load only what is necessary. Generate only what is necessary.*

## 🚨 SEARCH BEFORE GENERATE PIPELINE
Before generating any code, the AI **MUST** execute the following verification steps:
1. **Run Repository Search Engine**: Search the repo for existing Screens, Widgets, Services, Cubits, UseCases, Repositories, or Entities that match the requested feature.
2. **API Verification**: Verify parameters and return types before calling methods. Never guess APIs.
3. **Collision Detection**: Detect duplicate Class names, DI registrations, and Feature folders. Reuse or extend; do not duplicate.
4. **Generation**: Only write code after the above verification steps.

## 🚨 STRICT GENERATION & VALIDATION PIPELINE (MANDATORY)
Every AI agent must follow this generation pipeline:
1. Analyze Context
2. Analyze Repository
3. Load Framework
4. Load Project
5. Load Patterns
6. Load Validation Rules
7. Build Generation Plan
8. Generate Code
9. Semantic Validation
10. Auto Fix
11. Semantic Validation
12. Return Final Code

Generation must always be driven by the generation plan. The AI must prevent architectural violations instead of fixing them afterwards.

## 🚨 ARCHITECTURAL ENFORCEMENT
**Focused Cubit Architecture**:
- ALWAYS follow the Focused Cubit Architecture when generating presentation logic.
- Every independent user flow must have its own Cubit + State in a dedicated folder (e.g. `presentation/cubits/login/login_cubit.dart`).
- Never create a large Cubit responsible for multiple unrelated flows.
- **This rule has higher priority than repository detection. Always enforce it.**

## 🚨 RESPONSIVE SYSTEM
The project uses a responsive system (defined in `framework.json`).
Always generate responsive UI using the detected responsive framework. Do not hardcode raw values.
Never hardcode package-specific behavior unless verified by the framework.

## Global Rules
- **Never guess.**
- **Never duplicate code, classes, or registrations.**
- **Never invent APIs.**
- **Never violate folder structure.**
- **Always follow detected project patterns.**
