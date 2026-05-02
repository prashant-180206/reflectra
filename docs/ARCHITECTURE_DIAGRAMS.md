# System Architecture Diagram

## Component Interaction Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                        HOME SCREEN (UI)                         │
│  - Welcome Section                                              │
│  - Statistics Grid (StatCard)                                   │
│  - Feature Cards (FeatureCard)                                  │
│  - Quick Actions (QuickActionButton)                            │
│  - Recent Entries (RecentEntriesSection)                        │
└──────────────────────┬──────────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────────┐
│              RIVERPOD PROVIDERS (State Management)              │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────┐ │
│  │todayEntriesCount │  │totalEntriesCount │  │userPersona   │ │
│  └──────────────────┘  └──────────────────┘  └──────────────┘ │
│  ┌────────────────────┐  ┌──────────────┐  ┌────────────────┐ │
│  │lastThreeEntries   │  │customInstructions     │isPersonaConfigured│ │
│  └────────────────────┘  └──────────────┘  └────────────────┘ │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐│
│  │  dashboardStatsProvider (Combined - Main Consumer)        ││
│  │  Returns: DashboardStats model                             ││
│  └────────────────────────────────────────────────────────────┘│
└──────────────────────┬──────────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────────┐
│              DBSERVICE (Business Logic Layer)                   │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────┐ │
│  │  Diary Entries   │  │  Persona Ops     │  │ Instructions │ │
│  │  • getAll()      │  │  • save()        │  │ • save()     │ │
│  │  • getForDay()   │  │  • get()         │  │ • get()      │ │
│  │  • save()        │  │  • delete()      │  │ • delete()   │ │
│  │  • delete()      │  │  • has()         │  │ • has()      │ │
│  │  • count()       │  └──────────────────┘  └──────────────┘ │
│  └──────────────────┘                                           │
│  ┌────────────────────────────────────────────────────────────┐│
│  │  Statistics & Helpers                                      ││
│  │  • getDashboardStats()                                     ││
│  │  • getEntriesCountByMonth()                                ││
│  │  • getEntriesCountByDay()                                  ││
│  └────────────────────────────────────────────────────────────┘│
└──────────────────────┬──────────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────────┐
│            LEGACY CRUD CLASSES (Backwards Compatible)           │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────┐ │
│  │  EntryDb         │  │  PersonaDb       │  │CustomInstrDb │ │
│  │  (Delegates to   │  │  (Delegates to   │  │(Delegates to │ │
│  │   DbService)     │  │   DbService)     │  │ DbService)   │ │
│  └──────────────────┘  └──────────────────┘  └──────────────┘ │
└──────────────────────┬──────────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────────┐
│                  ISAR DATABASE (Persistence)                    │
│  ┌──────────────────┐  ┌──────────────────┐  ┌──────────────┐ │
│  │ DiaryEntry       │  │ Persona          │  │Custom        │ │
│  │ Collection       │  │ Collection       │  │Instruction   │ │
│  │ • id (PK)        │  │ • id (PK)        │  │Collection    │ │
│  │ • dayKey (Index) │  │ • identity       │  │• id (PK)     │ │
│  │ • createdAt      │  │ • personality    │  │• instructions│ │
│  │ • title          │  │ • goals          │  │              │ │
│  │ • content        │  │ • emotionalProfile│  │              │ │
│  └──────────────────┘  └──────────────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

## Widget Hierarchy

```
HomeScreen (HookConsumerWidget)
│
├── AppBar
│   └── Theme Toggle Button
│
├── SafeArea
│   └── ListView (Main Content)
│       │
│       ├── WelcomeCard
│       │   └── Daily Stats
│       │
│       ├── "Your Statistics" Section
│       │   └── GridView (2 columns)
│       │       ├── StatCard (Today's Entries)
│       │       ├── StatCard (Total Entries)
│       │       ├── StatCard (Persona Status)
│       │       └── StatCard (Instructions Status)
│       │
│       ├── "Setup & Configuration" Section
│       │   ├── FeatureCard (Persona Setup)
│       │   └── FeatureCard (Custom Instructions)
│       │
│       ├── "Quick Actions" Section
│       │   ├── QuickActionButton (Chat)
│       │   ├── QuickActionButton (View Saved)
│       │   └── QuickActionButton (Profile)
│       │
│       └── RecentEntriesSection
│           └── ListView
│               ├── Entry Item 1
│               ├── Entry Item 2
│               └── Entry Item 3
```

## Data Flow: Dashboard Load

```
1. Home Screen mounted
   │
   └─> ref.watch(dashboardStatsProvider)
       │
       └─> Riverpod evaluates provider
           │
           ├─> todayEntrieCountProvider
           │   └─> DbService.getEntriesCountByDay(DateTime.now())
           │       └─> Isar Query
           │
           ├─> totalEntrieCountProvider
           │   └─> DbService.countEntries()
           │       └─> Isar Count Query
           │
           ├─> lastThreeEntrieProvider
           │   └─> DbService.getLastThreeEntries()
           │       └─> Isar Query (limit: 3)
           │
           ├─> isPersonaConfiguredProvider
           │   └─> DbService.hasPersona()
           │       └─> Isar Get (id: 0)
           │
           └─> isCustomInstructionSetProvider
               └─> DbService.hasCustomInstruction()
                   └─> Isar Get (id: 0)

2. All providers complete
   │
   └─> DashboardStats model created
       │
       └─> AsyncValue.data(stats)
           │
           └─> _buildDashboard(stats)
               │
               └─> UI Renders with all data
```

## State Management Flow

```
User Action (Tap)
│
└─> notifier.refresh()
    │
    ├─> state = AsyncValue.loading()
    │
    └─> ref.refresh(dashboardStatsProvider)
        │
        └─> All dependent providers re-evaluate
            │
            ├─> New DB queries executed
            │
            └─> New DashboardStats created
                │
                └─> UI automatically updates
```

## Modular Benefits

### Separation of Concerns
- **UI Layer**: Widgets handle presentation only
- **State Layer**: Riverpod manages state lifecycle
- **Business Layer**: DbService contains logic
- **Persistence Layer**: Isar handles data

### Reusability
- Widgets can be used in other screens
- Providers can be composed with other providers
- DbService methods used throughout app

### Testability
- Mock providers in tests
- Mock DbService for unit tests
- Test widgets in isolation

### Maintainability
- Single responsibility per component
- Clear data flow
- Easy to locate and fix issues

### Scalability
- Easy to add new statistics
- New features just need new providers
- Can add new DbService methods without breaking existing code
