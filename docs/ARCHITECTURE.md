# Modular Home Screen & Database Architecture

## 📁 Directory Structure

```
lib/
├── core/
│   └── database/
│       ├── db_service.dart          ✨ NEW - Consolidated DB operations
│       ├── database.dart            (existing)
│       ├── crud/
│       │   ├── entry_db.dart        (updated - delegates to DbService)
│       │   ├── persona_db.dart      (updated - delegates to DbService)
│       │   └── custom_instruction_db.dart (updated - delegates to DbService)
│       ├── models/
│       │   ├── diary_entry.dart
│       │   ├── persona.dart
│       │   └── custom_instruction.dart
│       └── utils/
│           └── db_utils.dart
│
└── features/
    ├── home_screen.dart             (updated - comprehensive dashboard)
    ├── home_screen/
    │   ├── riverpod/
    │   │   └── home_provider.dart   ✨ NEW - Riverpod providers
    │   └── widgets/
    │       ├── dashboard_widgets.dart      ✨ NEW - Reusable widgets
    │       └── recent_entries_widget.dart  ✨ NEW - Recent entries display
    ├── saved/
    │   ├── riverpod/
    │   │   └── saved_controller.dart (updated - uses DbService)
    │   ├── widgets/
    │   │   ├── pagination_bar.dart   ✨ NEW - Pagination UI
    │   │   └── saved_list_item.dart
    │   └── saved_screen.dart        (updated - uses DbService)
    ├── daily/
    ├── entry/
    ├── profile/
    └── settings/
```

## 🎯 Key Components

### 1. DbService - Unified Database Layer
**Location:** `lib/core/database/db_service.dart`

Consolidates all database operations:
```dart
// Diary Entries
DbService.getAllEntries()
DbService.getEntriesForDay(date)
DbService.getLastThreeEntries()
DbService.countEntries()

// Persona
DbService.savePersona(persona)
DbService.getPersona()
DbService.hasPersona()

// Custom Instructions
DbService.saveCustomInstruction(instructions)
DbService.getCustomInstruction()
DbService.hasCustomInstruction()

// Statistics
DbService.getDashboardStats()
DbService.getEntriesCountByMonth(year, month)
DbService.getEntriesCountByDay(date)
```

### 2. Riverpod Providers - State Management
**Location:** `lib/features/home_screen/riverpod/home_provider.dart`

```dart
// Individual providers
ref.watch(todayEntrieCountProvider)
ref.watch(totalEntrieCountProvider)
ref.watch(lastThreeEntrieProvider)
ref.watch(userPersonaProvider)
ref.watch(customInstructionProvider)

// Combined provider
ref.watch(dashboardStatsProvider) // Returns DashboardStats model
```

### 3. Dashboard Widgets - Reusable UI Components
**Location:** `lib/features/home_screen/widgets/dashboard_widgets.dart`

```dart
// Statistics card
StatCard(
  title: 'Today\'s Entries',
  value: '5',
  icon: Icons.today,
  onTap: () => navigate(),
)

// Feature setup card
FeatureCard(
  title: 'Set Up Your Persona',
  description: 'Create your digital persona',
  icon: Icons.person_add,
  isConfigured: true,
  onTap: () => navigate(),
)

// Quick action button
QuickActionButton(
  label: 'Chat About Today',
  icon: Icons.chat_outlined,
  onPressed: () => navigate(),
)
```

### 4. Recent Entries Widget
**Location:** `lib/features/home_screen/widgets/recent_entries_widget.dart`

```dart
RecentEntriesSection(
  entries: entries,
  onViewAll: () => navigate(),
  onEntryTap: (entryId) => openEntry(entryId),
)
```

### 5. Pagination Bar
**Location:** `lib/features/saved/widgets/pagination_bar.dart`

```dart
PaginationBar(
  currentPage: 0,
  totalPages: 10,
  totalItems: 100,
  canGoPrev: false,
  canGoNext: true,
  onPrevious: () => goToPrevious(),
  onNext: () => goToNext(),
  onFirst: () => goToFirst(),
  onLast: () => goToLast(),
)
```

## 📊 Home Screen Dashboard Features

The new home screen displays:

1. **Welcome Section**
   - Greeting based on time of day
   - Today's entry count

2. **Statistics Grid**
   - Today's entries count
   - Total entries count
   - Persona status
   - Custom instructions status

3. **Setup & Configuration**
   - Feature cards with setup status
   - Direct navigation to profile/settings

4. **Quick Actions**
   - Chat about today
   - View saved entries
   - Profile management

5. **Recent Entries**
   - Last 3 entries with source indicator
   - Direct entry viewing
   - Date and time display

6. **Loading & Error States**
   - Skeleton loading cards
   - Error handling with retry option

## 🔄 Data Flow

```
Home Screen (UI)
    ↓
Riverpod Providers (State)
    ↓
DbService (Business Logic)
    ↓
Isar Database (Persistence)
```

## 🛠️ Usage Examples

### Display Dashboard Stats
```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  final stats = ref.watch(dashboardStatsProvider);
  
  return stats.when(
    loading: () => LoadingState(),
    error: (err, st) => ErrorState(),
    data: (data) => DashboardView(data: data),
  );
}
```

### Use Individual Providers
```dart
// Get today's entry count
final count = ref.watch(todayEntrieCountProvider);

// Get last three entries
final entries = ref.watch(lastThreeEntrieProvider);

// Check if persona is configured
final configured = ref.watch(isPersonaConfiguredProvider);
```

### Refresh Data
```dart
// Refresh entire dashboard
ref.refresh(dashboardStatsProvider);

// Refresh specific provider
ref.refresh(todayEntrieCountProvider);
```

## ✅ Backwards Compatibility

Old CRUD classes still work but delegate to DbService:
```dart
// Both work, but new code should use DbService
EntryDb.getAllEntries()  // Still works
DbService.getAllEntries() // Preferred
```

## 🎨 Customization

### Change Page Size for Pagination
```dart
notifier.setPageSize(20); // 10, 20, or 50
```

### Filter by Month
```dart
notifier.setMonthLabel('January 2024');
```

### Navigate Between Pages
```dart
notifier.nextPage();
notifier.prevPage();
notifier.goToFirstPage();
notifier.goToLastPage();
```

## 📈 Future Enhancements

- [ ] Add monthly/yearly statistics charts
- [ ] Implement entry search functionality
- [ ] Add entry tagging system
- [ ] Create backup/export features
- [ ] Add entry analytics dashboard
- [ ] Implement offline sync

## 📝 Notes

- All Riverpod providers auto-refresh when dependencies change
- DbService handles all database transactions safely
- Widgets are fully composable and reusable
- Pagination supports custom page sizes and filtering
