# Database Schema & Models

## 📊 Collections

### DiaryEntry Collection
Stores all diary entries from manual writing and AI conversations.

```dart
@collection
class DiaryEntry {
  int id;                    // Primary Key, auto-incremented
  @Index()
  int dayKey;                // Index for day-based queries (YYYYMMDD format)
  @Index()
  DateTime createdAt;        // Index for sorting
  DateTime? updatedAt;       // Last modification time
  String title;              // Entry title
  String content;            // Full entry content
  String source;             // 'manual' or 'ai'
}
```

**Usage:**
- Store daily entries created by user
- Store AI-generated entries from chat
- Query entries by day using dayKey
- Paginate and sort by createdAt

**Example:**
```dart
// Create entry
DiaryEntry entry = DiaryEntry(
  dayKey: DbUtils.dayKeyFromDate(DateTime.now()),
  createdAt: DateTime.now(),
  title: 'My Day',
  content: 'Today was great...',
  source: 'manual',
);

// Save
final id = await DbService.saveEntry(entry);

// Query by day
final todayEntries = await DbService.getEntriesForDay(DateTime.now());

// Count
final count = await DbService.countEntries();
```

---

### Persona Collection
Stores user's AI persona/profile information (singleton - only one record).

```dart
@collection
class Persona {
  int id = 0;                                  // Always 0 (singleton)
  Identity? identity;                          // User's identity info
  Personality? personality;                    // Personality traits
  Interests? interests;                        // User interests
  CommunicationPreferences? communicationPreferences;  // Comm preferences
  Goals? goals;                                // User goals
  EmotionalProfile? emotionalProfile;          // Emotional patterns
  String additionalContext = '';               // Extra info
}
```

**Nested Objects:**

```dart
@embedded
class Identity {
  String? preferredName;       // Name for AI to use
  String? ageRange;            // Age bracket (e.g., "25-35")
  String? occupationOrField;   // Job/field
  String? region;              // Geographic region
}

@embedded
class Personality {
  String? traits;              // Personality traits
  String? thinkingStyle;       // How they think
  String? energyPattern;       // Energy levels
  // More fields...
}

@embedded
class Interests {
  String? hobbies;             // Hobbies list
  String? skills;              // Skills
  String? topics;              // Interested topics
  // More fields...
}

@embedded
class CommunicationPreferences {
  String? tone;                // Preferred tone
  String? language;            // Language preference
  String? style;               // Communication style
  // More fields...
}

@embedded
class Goals {
  String? shortTerm;           // Short-term goals
  String? longTerm;            // Long-term goals
  String? milestones;          // Milestones
  // More fields...
}

@embedded
class EmotionalProfile {
  String? stressors;           // What causes stress
  String? comforts;            // What provides comfort
  String? triggers;            // Emotional triggers
  // More fields...
}
```

**Usage:**
- Store once during setup
- Retrieve for AI context
- Update when user changes

**Example:**
```dart
// Create persona
Persona persona = Persona(
  identity: Identity(
    preferredName: 'Alex',
    ageRange: '25-35',
    occupationOrField: 'Software Engineer',
    region: 'North America',
  ),
  personality: Personality(
    traits: 'Introverted, analytical',
    thinkingStyle: 'Logical',
  ),
);

// Save (overwrites existing)
await DbService.savePersona(persona);

// Retrieve
final persona = await DbService.getPersona();

// Check if exists
final exists = await DbService.hasPersona();
```

---

### CustomInstruction Collection
Stores user's custom instructions for AI (singleton - only one record).

```dart
@collection
class CustomInstruction {
  int id = 0;           // Always 0 (singleton)
  String instructions;  // User's custom instructions
}
```

**Usage:**
- Store custom AI behavior instructions
- Retrieved when generating AI responses
- User can edit anytime

**Example:**
```dart
// Save instructions
String instructions = '''
Always respond concisely.
Use markdown formatting.
Ask clarifying questions.
''';
await DbService.saveCustomInstruction(instructions);

// Retrieve
final ci = await DbService.getCustomInstruction();
print(ci?.instructions);

// Check if set
final hasInstructions = await DbService.hasCustomInstruction();
```

---

## 📈 Query Examples

### Statistics Queries

```dart
// Today's entry count
int todayCount = await DbService.getEntriesCountByDay(DateTime.now());

// Specific month count
int monthCount = await DbService.getEntriesCountByMonth(2024, 1);

// Total entries
int total = await DbService.countEntries();

// Last 3 entries
List<DiaryEntry> recent = await DbService.getLastThreeEntries();

// All entries
List<DiaryEntry> all = await DbService.getAllEntries();

// Get entries for specific day
List<DiaryEntry> day = await DbService.getEntriesForDay(
  DateTime(2024, 1, 15),
);

// Paginated query
List<DiaryEntry> page = await DbService.getEntriesWithPagination(
  limit: 10,
  offset: 0,
);
```

---

## 🔑 Index Explanation

### dayKey Index
- **Purpose**: Fast queries for entries on specific days
- **Format**: YYYYMMDD (e.g., 20240115 for Jan 15, 2024)
- **Benefit**: O(log n) lookup instead of O(n)
- **Example**: Query all entries for a specific date

### createdAt Index
- **Purpose**: Fast sorting and range queries
- **Benefit**: Efficient pagination and sorting
- **Example**: Get 10 most recent entries

---

## 🔄 Data Relationships

```
Persona (1)              CustomInstruction (1)        DiaryEntry (many)
  ├─ Identity               ├─ instructions            ├─ id
  ├─ Personality            └─ (singleton)             ├─ dayKey ◄── Query by date
  ├─ Interests                                         ├─ createdAt ◄── Sort/Paginate
  ├─ Communication          Used for AI                ├─ title
  ├─ Goals                  responses when            ├─ content
  ├─ Emotional              generating                ├─ source
  └─ (singleton)            diary entries             └─ updatedAt
    
    Used for AI              Used for AI                 User's journal
    personalization          behavior/rules            entries & AI chats
```

---

## 💾 Data Persistence

### Database File Location
- **Android**: `getApplicationDocumentsDirectory()/mindlog_diary_v2.isar`
- **iOS**: `getApplicationDocumentsDirectory()/mindlog_diary_v2.isar`
- **Web**: IndexedDB (browser storage)

### Database Name
- `mindlog_diary_v2` (allows versioning)

### Backup
```dart
// Reset database (dev only)
await DbService.resetDatabase();
```

---

## 🔒 Data Safety

### Transactions
All write operations use transactions:
```dart
_isar.write((isar) {
  // Multiple operations execute atomically
  isar.diaryEntrys.put(entry);
  isar.personas.put(persona);
});
```

### Auto-Increment
Entry IDs are auto-incremented:
```dart
if (entry.id <= 0) {
  entry.id = isar.diaryEntrys.autoIncrement();
}
```

### Timestamps
- `createdAt`: Set when created, never changed
- `updatedAt`: Set when created, updated on modification

---

## 📝 Utility Functions

### DbUtils

```dart
// Convert DateTime to dayKey
int dayKey = DbUtils.dayKeyFromDate(DateTime(2024, 1, 15));
// Result: 20240115

// Convert dayKey back to DateTime
DateTime date = DbUtils.dateFromDayKey(20240115);
// Result: 2024-01-15 00:00:00
```

---

## 🚀 Performance Notes

- **Indexes** are automatically optimized by Isar
- **Queries** are lazy (only fetch needed data)
- **Collections** are schema-validated
- **Pagination** recommended for large datasets
- **Counts** are O(1) operations

---

## 🔧 Maintenance

### View Database
- Use Isar Inspector (dev tool)
- Check file in app documents

### Clean Up
```dart
// Delete old entries (example)
final entries = await DbService.getAllEntries();
for (final entry in entries) {
  if (entry.createdAt.isBefore(DateTime.now().subtract(Duration(days: 365)))) {
    await DbService.deleteEntry(entry.id);
  }
}
```

### Verify Integrity
```dart
// Check entry count
final count = await DbService.countEntries();
debugPrint('Total entries: $count');

// Verify recent entries
final recent = await DbService.getLastThreeEntries();
debugPrint('Recent entries: ${recent.length}');
```
