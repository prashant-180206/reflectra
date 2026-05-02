# Quick Start Guide - Modular Architecture

## 🚀 Getting Started

### For New Features

#### 1. Display Statistics on Home Screen
```dart
// In home_provider.dart, create a new provider:
@riverpod
Future<int> myNewStat(MyNewStatRef ref) async {
  return DbService.getMyNewStat();
}

// Then watch it in home_screen.dart:
final myStat = ref.watch(myNewStatProvider);
```

#### 2. Add a New Widget
```dart
// Create in lib/features/home_screen/widgets/
class MyNewWidget extends StatelessWidget {
  final String data;
  
  @override
  Widget build(BuildContext context) {
    return Container(/*...*/);
  }
}

// Use in home_screen.dart:
MyNewWidget(data: 'value')
```

#### 3. Add Database Operations
```dart
// Add to DbService:
static Future<List<MyModel>> getMyData() async {
  return _isar.myModels.where().findAll();
}

// Then use via provider or directly
```

## 🎯 Common Tasks

### Show Loading State While Fetching
```dart
final data = ref.watch(myProvider);

return data.when(
  loading: () => CircularProgressIndicator(),
  error: (err, st) => ErrorWidget(),
  data: (value) => MyWidget(data: value),
);
```

### Refresh Data After Changes
```dart
// In a callback:
ref.refresh(dashboardStatsProvider);

// Or individual provider:
ref.refresh(todayEntrieCountProvider);
```

### Navigate and Refresh
```dart
onTap: () async {
  await EntryViewerRoute(entryId: id).push(context);
  ref.refresh(dashboardStatsProvider);
}
```

### Use DbService Directly
```dart
final entries = await DbService.getAllEntries();
final count = await DbService.countEntries();
final today = await DbService.getEntriesCountByDay(DateTime.now());
```

## 🏗️ File Organization

```
Feature Feature
├── widgets/          # UI Components
│   ├── my_widget.dart
│   └── another_widget.dart
├── riverpod/         # State Management
│   └── my_controller.dart
└── my_screen.dart    # Main Screen
```

## 🔧 Best Practices

### ✅ DO:
- Use DbService for all database operations
- Create reusable widgets
- Use Riverpod for state management
- Keep widgets small and focused
- Use meaningful names

### ❌ DON'T:
- Access Isar directly (use DbService)
- Put business logic in widgets
- Create deeply nested widgets
- Use global variables
- Mix concerns

## 📊 Adding New Statistics

1. **Add to DbService:**
```dart
static Future<int> getMyNewStat() async {
  // Your logic here
}
```

2. **Create Provider:**
```dart
@riverpod
Future<int> myNewStat(MyNewStatRef ref) async {
  return DbService.getMyNewStat();
}
```

3. **Add to DashboardStats:**
```dart
class DashboardStats {
  // ... existing fields
  final int myNewStat;  // Add here
  
  DashboardStats({
    // ... existing params
    required this.myNewStat,  // Add here
  });
}
```

4. **Update dashboardStatsProvider:**
```dart
@riverpod
Future<DashboardStats> dashboardStats(DashboardStatsRef ref) async {
  // ... existing code
  final newStat = await ref.watch(myNewStatProvider.future);  // Add here
  
  return DashboardStats(
    // ... existing fields
    myNewStat: newStat,  // Add here
  );
}
```

5. **Display in Home Screen:**
```dart
StatCard(
  title: 'My New Stat',
  value: stats.myNewStat.toString(),
  icon: Icons.my_icon,
  onTap: () => navigateToDetail(),
)
```

## 🎨 Styling

### Use Theme Consistently:
```dart
final theme = Theme.of(context);

Container(
  color: theme.primaryColor,
  child: Text(
    'My Text',
    style: theme.textTheme.titleMedium,
  ),
)
```

### Responsive Spacing:
```dart
SizedBox(
  height: 12,  // Use multiples of 4 or 8
  child: child,
)
```

### Dark Mode Support:
```dart
final isDark = theme.brightness == Brightness.dark;
color: isDark ? Colors.grey[800] : Colors.grey[100]
```

## 🐛 Debugging

### Check Provider Value:
```dart
final value = ref.read(myProvider);
debugPrint('Provider value: $value');
```

### Force Refresh:
```dart
ref.invalidate(myProvider);  // Clears cache
ref.refresh(myProvider);      // Refetch data
```

### Database Operations:
```dart
// Log database operations
DbService.getAllEntries().then((entries) {
  debugPrint('Found ${entries.length} entries');
});
```

## 📝 Examples

### Simple Stat Card
```dart
StatCard(
  title: 'My Data',
  value: count.toString(),
  icon: Icons.data_usage,
  onTap: () => detailScreen(),
)
```

### Feature Card
```dart
FeatureCard(
  title: 'My Feature',
  description: 'Feature description',
  icon: Icons.feature,
  isConfigured: isSetup,
  onTap: () => setupScreen(),
)
```

### Quick Action
```dart
QuickActionButton(
  label: 'Do Something',
  icon: Icons.action,
  onPressed: () => doSomething(),
)
```

### Recent Items List
```dart
RecentEntriesSection(
  entries: items,
  onViewAll: () => viewAll(),
  onEntryTap: (id) => openDetail(id),
)
```

## 🚨 Troubleshooting

### Provider Not Updating?
- Check if dependencies are correct
- Use `ref.refresh()` instead of `ref.read()`
- Check if watch/read is in correct context

### Widget Not Rebuilding?
- Ensure using `.watch()` not `.read()`
- Check if state changed (immutability)
- Use DevTools to inspect provider

### Database Issues?
- Check if Database.init() was called
- Verify model schemas match
- Check permissions for mobile platforms

## 📚 Resources

- [ARCHITECTURE.md](./ARCHITECTURE.md) - Full architecture guide
- [ARCHITECTURE_DIAGRAMS.md](./ARCHITECTURE_DIAGRAMS.md) - Visual diagrams
- [Flutter Riverpod Docs](https://riverpod.dev/)
- [Isar Database Docs](https://isar.dev/)
