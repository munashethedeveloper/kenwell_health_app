# Wellness Flow Diagram

## Dynamic Flow Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         CONSENT SCREEN                          │
│                                                                 │
│  Checkboxes: [ ] HRA  [ ] VCT  [ ] TB  [ ] HIV                │
│                                                                 │
│  Validation: At least ONE must be checked                      │
└─────────────────────────┬───────────────────────────────────────┘
                          │
                          ▼
              ┌───────────────────────┐
              │ User clicks "Next"    │
              │ Flow Initialized      │
              └───────────┬───────────┘
                          │
                          ▼
    ┌─────────────────────────────────────────────┐
    │   Build Flow Based on Selected Checkboxes   │
    └─────────────────────┬───────────────────────┘
                          │
        ┌─────────────────┼─────────────────┐
        │                 │                 │
        ▼                 ▼                 ▼
   ┌────────┐      ┌──────────┐      ┌─────────┐
   │  HRA?  │      │ HIV/VCT? │      │   TB?   │
   └───┬────┘      └────┬─────┘      └────┬────┘
       │                │                  │
       │ Yes            │ Yes              │ Yes
       ▼                ▼                  ▼
```

## Flow Paths by Checkbox Selection

### Path 1: HRA Selected ✓
```
Consent
   ↓
Personal Details (HRA)
   ↓
Risk Assessment (HRA)
   ↓
Screening Results (HRA)
   ↓
Nurse Intervention*
   ↓
Survey (Always)
```

### Path 2: HIV/VCT Selected ✓
```
Consent
   ↓
Nurse Intervention*
   ↓
HIV Test
   ↓
HIV Results
   ↓
HIV Nurse Intervention
   ↓
Survey (Always)
```

### Path 3: TB Selected ✓
```
Consent
   ↓
Nurse Intervention*
   ↓
TB Test
   ↓
TB Nurse Intervention
   ↓
Survey (Always)
```

### Path 4: HRA + HIV Selected ✓✓
```
Consent
   ↓
Personal Details (HRA)
   ↓
Risk Assessment (HRA)
   ↓
Screening Results (HRA)
   ↓
Nurse Intervention*
   ↓
HIV Test
   ↓
HIV Results
   ↓
HIV Nurse Intervention
   ↓
Survey (Always)
```

### Path 5: HRA + TB Selected ✓✓
```
Consent
   ↓
Personal Details (HRA)
   ↓
Risk Assessment (HRA)
   ↓
Screening Results (HRA)
   ↓
Nurse Intervention*
   ↓
TB Test
   ↓
TB Nurse Intervention
   ↓
Survey (Always)
```

### Path 6: HIV + TB Selected ✓✓
```
Consent
   ↓
Nurse Intervention*
   ↓
HIV Test
   ↓
HIV Results
   ↓
HIV Nurse Intervention
   ↓
TB Test
   ↓
TB Nurse Intervention
   ↓
Survey (Always)
```

### Path 7: ALL Selected ✓✓✓✓
```
Consent
   ↓
Personal Details (HRA)
   ↓
Risk Assessment (HRA)
   ↓
Screening Results (HRA)
   ↓
Nurse Intervention*
   ↓
HIV Test
   ↓
HIV Results
   ↓
HIV Nurse Intervention
   ↓
TB Test
   ↓
TB Nurse Intervention
   ↓
Survey (Always)
```

## Flow Decision Tree

```
                           START
                             |
                        [CONSENT]
                             |
                    User Selects Checkboxes
                             |
              ┌──────────────┼──────────────┐
              |              |              |
           [HRA?]         [HIV/VCT?]     [TB?]
              |              |              |
        ┌─────┴─────┐  ┌─────┴─────┐ ┌─────┴─────┐
       YES          NO YES         NO YES        NO
        |              |              |
        |              |              |
    Add HRA        Add HIV         Add TB
    Screens        Screens        Screens
        |              |              |
        └──────────────┴──────────────┘
                       |
              [Nurse Intervention]*
                       |
                  [SURVEY]
                       |
                      END
```

## Screen Flow Sequence Visualization

```
Step #  |  Screen Name              |  Condition
--------|---------------------------|------------------------------------------
   0    |  Consent                  |  Always shown (entry point)
   ?    |  Personal Details         |  If HRA selected
   ?    |  Risk Assessment          |  If HRA selected
   ?    |  Screening Results        |  If HRA selected
   ?    |  Nurse Intervention       |  If any screening selected
   ?    |  HIV Test                 |  If HIV or VCT selected
   ?    |  HIV Results              |  If HIV or VCT selected
   ?    |  HIV Nurse Intervention   |  If HIV or VCT selected
   ?    |  TB Test                  |  If TB selected
   ?    |  TB Nurse Intervention    |  If TB selected
  Last  |  Survey                   |  Always shown (exit point)
```

*Note: Step numbers are dynamic and depend on selections*

## Key Decision Points

### 1. Consent Screen Validation
```
┌────────────────────────────────────┐
│  Are any checkboxes selected?     │
├────────────────────────────────────┤
│  YES → Initialize flow & proceed  │
│  NO  → Show error message         │
└────────────────────────────────────┘
```

### 2. Flow Initialization Logic
```python
def initializeFlow(selectedScreenings):
    flow = ['consent']
    
    # Add HRA flow
    if 'hra' in selectedScreenings:
        flow += ['personal_details', 'risk_assessment', 'screening_results']
    
    # Add nurse intervention if anything selected
    if selectedScreenings:
        flow += ['nurse_intervention']
    
    # Add HIV flow (VCT and HIV are same)
    if 'hiv' in selectedScreenings or 'vct' in selectedScreenings:
        flow += ['hiv_test', 'hiv_results', 'hiv_nurse_intervention']
    
    # Add TB flow
    if 'tb' in selectedScreenings:
        flow += ['tb_test', 'tb_nurse_intervention']
    
    # Always add survey at the end
    flow += ['survey']
    
    return flow
```

### 3. Navigation Logic
```
Current Step: N
Total Steps: M

Previous Button:
  ├─ If N > 0: Go to step N-1
  └─ If N = 0: Cancel flow

Next Button:
  ├─ If N < M-1: Go to step N+1
  └─ If N = M-1: Submit & Exit
```

## Screen Dependencies

```
┌─────────────────┐
│  Consent        │ ← Entry point (no dependencies)
└────────┬────────┘
         │
    ┌────┴────┐
    │ HRA     │
    │ Screens │ ← Depend on HRA checkbox
    └────┬────┘
         │
    ┌────┴────────┐
    │   Nurse     │
    │ Intervention│ ← Depends on ANY checkbox
    └────┬────────┘
         │
    ┌────┴────────┐
    │  HIV/TB     │
    │  Screens    │ ← Depend on respective checkboxes
    └────┬────────┘
         │
    ┌────┴────────┐
    │   Survey    │ ← Always shown (no dependencies)
    └─────────────┘
```

## State Management Flow

```
┌──────────────────────────────────────────────────────────┐
│             WellnessFlowViewModel                        │
├──────────────────────────────────────────────────────────┤
│                                                          │
│  State:                                                  │
│  ├─ _flowSteps: List<String>                           │
│  ├─ _currentStep: int                                   │
│  └─ consentVM: ConsentScreenViewModel                   │
│                                                          │
│  Methods:                                                │
│  ├─ initializeFlow(selectedScreenings)                  │
│  │   └─ Builds _flowSteps based on selections          │
│  ├─ nextStep()                                          │
│  │   └─ Increments _currentStep                        │
│  ├─ previousStep()                                      │
│  │   └─ Decrements _currentStep                        │
│  └─ currentStepName                                     │
│      └─ Returns _flowSteps[_currentStep]               │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

## Validation Flow

```
                    ┌─────────────┐
                    │ User clicks │
                    │   "Next"    │
                    └──────┬──────┘
                           │
                    ┌──────▼──────┐
                    │  Validate   │
                    │  Checkboxes │
                    └──────┬──────┘
                           │
                ┌──────────┴──────────┐
                │                     │
                ▼                     ▼
          ┌──────────┐         ┌──────────┐
          │ At least │         │   None   │
          │   one    │         │ selected │
          │ selected │         └────┬─────┘
          └────┬─────┘              │
               │                    ▼
               │              ┌──────────┐
               │              │  Show    │
               │              │  Error   │
               │              └──────────┘
               │
               ▼
        ┌──────────┐
        │ Validate │
        │  Form    │
        └────┬─────┘
             │
      ┌──────┴──────┐
      │             │
      ▼             ▼
┌─────────┐   ┌─────────┐
│  Valid  │   │ Invalid │
└────┬────┘   └────┬────┘
     │             │
     ▼             ▼
┌─────────┐   ┌─────────┐
│Initialize│  │  Show   │
│   Flow   │  │  Error  │
└────┬────┘   └─────────┘
     │
     ▼
┌─────────┐
│ Proceed │
│ to next │
│ screen  │
└─────────┘
```

## Summary

- **Entry Point**: Consent screen (always step 0)
- **Dynamic Routing**: Flow steps determined by checkbox selections
- **Required Selection**: At least one checkbox must be selected
- **Exit Point**: Survey screen (always last step)
- **Navigation**: Previous/Next buttons bound-checked against dynamic flow length
- **Validation**: Multi-level validation (checkboxes + form fields + signature)

---

*This diagram illustrates the refactored wellness flow architecture that supports dynamic screen routing based on user consent selections.*
