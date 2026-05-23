## Sundae — Working Brief

**Tagline:** Your Sunday-prep co-pilot for hitting macros all week.

### Core Human Driver
**Esteem & consistency.** Fitness-focused users want to feel in control of their nutrition without spending Sundays doing "macro Tetris." Sundae rewards a single weekly planning ritual that pays off across 7 days of eating.

### Target Audience
Fitness/macro-focused users (gym-goers, lifters, recomp / cut / lean-bulk) who already know roughly what they want to eat but hate the planning and shopping admin. Aesthetic feels serious, capable, and slightly performance-coded — not childish, not clinical hospital-app.

### Core Action & North Star
- **Core action:** Build a weekly meal plan that hits target macros, then execute the Sunday prep + grocery run from it.
- **North star:** % of weeks where the user completes a Sunday prep session from a saved plan.

### v1 Features
- Recipe library with filters (diet, time, protein/calorie range)
- Weekly planner: assign recipes to meal slots across the week
- Servings & macro scaling per recipe; daily macro totals vs. target
- Auto grocery list grouped by aisle (produce, protein, pantry, dairy, frozen)
- Pantry tracking — items already owned get subtracted from the grocery list
- Sunday prep day: step-by-step batched schedule (chop everything → roast trays → simmer → portion containers)

### Non-Goals (v1)
- Real-time barcode calorie tracking (Sundae plans, doesn't log every bite)
- Social feed / sharing community
- Instacart / grocery delivery integration
- Custom recipe creation by user (curated library only in v1)

### Screen Map (v1)
1. **Today / This Week** — current day's meals, macro rings, "Prep Day" CTA
2. **Planner** — 7-day grid, tap a slot to add/swap a recipe
3. **Recipes** — searchable library with filters, recipe detail with scalable servings + macros
4. **Grocery List** — aisle-grouped checklist, pantry toggle per item
5. **Prep Day** — ordered batch-cook schedule with timers
6. **Profile / Goals** — macro targets, dietary prefs, pantry

### UX Patterns to Mirror
- **Eat This Much** — closed loop from plan → auto grocery list → virtual pantry; granular meal regenerate/swap; pie-chart + progress-bar macro feedback.
- **Mealime** — grocery list grouped by store department, auto-merged ingredient quantities, smart categorization.
- **MacroPlan / Prospre** — "generate a plan from my macros + prep day + container count" as the hero action; lifter-tool aesthetic.
- **CalAI / AI Coach pattern** — onboarding as a personalization quiz that ends in a "your plan is ready" reveal.

### Data Model (rough)
- `Recipe { id, title, image, time, servings, macros{kcal,p,c,f}, ingredients[], steps[], tags[] }`
- `Ingredient { id, name, aisle, unit }`
- `MealPlan { weekStart, slots: [{ day, mealType, recipeId, servings }] }`
- `PantryItem { ingredientId, qty, unit }`
- `UserProfile { macroTargets, diet, allergies, prepDay, containers }`

### Data / Integration Stance
**Mock-first MVP.** Ship with a curated local recipe library (~30-50 recipes) and on-device persistence (SwiftData). No accounts, no backend, no AI generation in v1 — the "plan generator" is a deterministic algorithm that picks recipes whose macros sum closest to targets.

### Onboarding
`personalization-quiz`: goal → macro targets (or TDEE calculator) → diet/allergies → prep day → number of containers → reveal first week's plan.

## Pre-Build Confirmation

### v1 Features (locked)
- Personalization-quiz onboarding ending in a generated first week
- Today / This Week home with macro rings + Prep Day CTA
- 7-day Planner grid with tap-to-swap recipe slots
- Recipe library + detail with scalable servings and live macro recalculation
- Auto grocery list, aisle-grouped, with pantry subtraction
- Prep Day batched cook schedule with timers
- Profile / Goals: macro targets, diet, allergies, prep day, container count, pantry

### Explicit Exclusions (v1)
- No barcode scanning or per-bite calorie logging
- No social feed, sharing, or community
- No Instacart / grocery delivery integration
- No user-created recipes (curated library only)
- No accounts, sync, or cloud backend
- No live AI plan generation (deterministic algorithm instead)

### First Screens to Build
1. Personalization-quiz onboarding → plan reveal
2. Today / This Week home with macro rings
3. Planner grid + recipe swap sheet
4. Recipe detail with serving scaler
5. Grocery list (aisle-grouped, pantry toggle)
6. Prep Day batch schedule

### Design System
- **Reference:** MacroFactor — serious, data-dense, lifter-coded, high-contrast, chart-forward
- **Palette:** Lifter Charcoal
  - background `#0E0F0D`
  - surface `#1A1C18`
  - primary / text `#F5F5F4`
  - accent `#C6F432`
- **Catalog seed:** `ai-coach`
- Big numeric readouts, tight macro rings/bars, lime accent reserved for the primary action and "on target" states.

### Onboarding Choice
`personalization-quiz` — ends with a "your first week is ready" plan reveal.

### Data / Integration Stance
Mock-first. Local SwiftData persistence, curated seed recipes, deterministic plan generator. No integrations, no secrets, no accounts in v1.

### Open Questions (non-blocking)
- TDEE calculator vs. direct macro entry in onboarding (default: offer both, calculator as primary)
- Solo cooking only in v1 (family/multi-person scaling deferred)