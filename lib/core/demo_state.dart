import 'package:flutter/widgets.dart';

enum Role { guard, supervisor }

class Checkpoint {
  Checkpoint(this.name, this.method, {this.doneAt, this.doneBy});
  final String name;
  final String method;
  String? doneAt;
  String? doneBy;
  bool get done => doneAt != null;
}

class RouteStop {
  RouteStop(this.name, this.window, this.status);
  final String name;
  final String window;
  String status;
}

class ChatMessage {
  ChatMessage(this.text, this.mine, this.meta);
  final String text;
  final bool mine;
  final String meta;
}

class ApprovalItem {
  ApprovalItem(this.id, this.person, this.type);
  final String id;
  final String person;
  final String type;
}

class LogEntry {
  LogEntry(this.title, this.subtitle);
  final String title;
  final String subtitle;
}

/// In-memory state so the demo behaves like a real app (clock-in, patrols,
/// approvals, chat...). Nothing is persisted; restart the app to reset.
class DemoState extends ChangeNotifier {
  Role role = Role.guard;

  String get userName => role == Role.guard ? 'Alex Morgan' : 'Priya Shah';
  String get firstName => role == Role.guard ? 'Alex' : 'Priya';
  String get initials => role == Role.guard ? 'AM' : 'PS';
  String get homeRoute => role == Role.guard ? '/m07' : '/m08';

  void setRole(Role r) {
    role = r;
    notifyListeners();
  }

  // ---------- Attendance ----------
  DateTime? clockInAt;
  DateTime? clockOutAt;
  DateTime? breakStartedAt;
  bool get clockedIn => clockInAt != null && clockOutAt == null;
  bool get onBreak => breakStartedAt != null;

  void clockIn() {
    clockInAt = DateTime.now();
    clockOutAt = null;
    notifyListeners();
  }

  void clockOut() {
    clockOutAt = DateTime.now();
    breakStartedAt = null;
    notifyListeners();
  }

  void startBreak() {
    breakStartedAt = DateTime.now();
    notifyListeners();
  }

  void endBreak() {
    breakStartedAt = null;
    notifyListeners();
  }

  // ---------- Patrol ----------
  final List<Checkpoint> checkpoints = [
    Checkpoint('West entrance', 'QR', doneAt: '07:08', doneBy: 'QR'),
    Checkpoint('Parking perimeter', 'GPS', doneAt: '07:12', doneBy: 'GPS'),
    Checkpoint('North gate', 'NFC'),
    Checkpoint('Loading dock', 'QR'),
    Checkpoint('East exit', 'QR'),
    Checkpoint('Control room', 'NFC'),
  ];
  int get checkpointsDone => checkpoints.where((c) => c.done).length;
  Checkpoint? get nextCheckpoint {
    for (final c in checkpoints) {
      if (!c.done) return c;
    }
    return null;
  }

  int linkedIncidents = 0;

  void completeNextCheckpoint(String method) {
    final c = nextCheckpoint;
    if (c == null) return;
    c.doneAt = hhmm(DateTime.now());
    c.doneBy = method;
    notifyListeners();
  }

  void addLinkedIncident() {
    linkedIncidents++;
    notifyListeners();
  }

  void resetTour() {
    for (var i = 2; i < checkpoints.length; i++) {
      checkpoints[i].doneAt = null;
      checkpoints[i].doneBy = null;
    }
    linkedIncidents = 0;
    notifyListeners();
  }

  // ---------- Supervisor route ----------
  final List<RouteStop> stops = [
    RouteStop('Office tower', '08:00–08:12', 'Completed'),
    RouteStop('Retail plaza', '08:24–08:40', 'Completed'),
    RouteStop('Construction site', 'ETA 09:17', 'Next'),
    RouteStop('Warehouse', 'ETA 10:06', 'Upcoming'),
  ];
  int get stopsDone => stops.where((s) => s.status == 'Completed' || s.status == 'Skipped').length;

  void completeCurrentStop({bool skipped = false}) {
    for (var i = 0; i < stops.length; i++) {
      if (stops[i].status == 'Next') {
        stops[i].status = skipped ? 'Skipped' : 'Completed';
        if (i + 1 < stops.length) stops[i + 1].status = 'Next';
        break;
      }
    }
    notifyListeners();
  }

  void resetRoute() {
    stops[2].status = 'Next';
    stops[3].status = 'Upcoming';
    notifyListeners();
  }

  RouteStop? get currentStop {
    for (final s in stops) {
      if (s.status == 'Next') return s;
    }
    return null;
  }

  // ---------- Approvals ----------
  final List<ApprovalItem> approvals = [
    ApprovalItem('REQ-108', 'Alex Morgan', 'Punch correction • due in 2h'),
    ApprovalItem('REQ-114', 'Jordan Lee', 'Equipment replacement • \$85'),
    ApprovalItem('REQ-116', 'Taylor Reed', 'Mileage claim • 42.6 km'),
  ];
  final List<LogEntry> approvalHistory = [
    LogEntry('REQ-103 • Uniform exchange', 'Approved • yesterday 16:22'),
    LogEntry('REQ-089 • Shift swap', 'Rejected • reason recorded'),
  ];

  void decide(String id, String outcome) {
    final idx = approvals.indexWhere((a) => a.id == id);
    if (idx < 0) return;
    final a = approvals.removeAt(idx);
    approvalHistory.insert(0, LogEntry('${a.id} • ${a.type.split(' • ').first}', '$outcome • today ${hhmm(DateTime.now())}'));
    notifyListeners();
  }

  // ---------- Messages ----------
  final List<ChatMessage> chat = [
    ChatMessage('Please confirm your ETA to Warehouse. The keyholder is expecting you.', false, '08:21 • Dispatch'),
    ChatMessage('En route. Current ETA 08:29. I will confirm arrival by GPS.', true, '08:22 • Read'),
    ChatMessage('Received. Contact us before entering the premises.', false, '08:23 • Dispatch'),
  ];

  void sendChat(String text) {
    chat.add(ChatMessage(text, true, '${hhmm(DateTime.now())} • Sent'));
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 1600), () {
      chat.add(ChatMessage('Copy that. Logged on ticket ALM-208.', false, '${hhmm(DateTime.now())} • Dispatch'));
      notifyListeners();
    });
  }

  // ---------- Logs ----------
  final List<LogEntry> passdowns = [
    LogEntry('Jordan Lee • 06:45', 'North gate latch intermittent. Maintenance informed.'),
    LogEntry('Priya Shah • yesterday', 'Delivery entrance closed after 20:00.'),
    LogEntry('Alex Morgan • draft', 'Temporary repair checked at 10:00.'),
  ];

  void addPassdown(String text) {
    passdowns.insert(0, LogEntry('$userName • ${hhmm(DateTime.now())}', text));
    notifyListeners();
  }

  final List<LogEntry> visitors = [
    LogEntry('Taylor Reed • Contractor', 'Checked out 07:52'),
  ];

  void addVisitor(String name, String host) {
    visitors.insert(0, LogEntry(name, 'Checked in ${hhmm(DateTime.now())} • host: $host'));
    notifyListeners();
  }

  // ---------- Misc ----------
  int unreadNotifications = 4;
  void readNotifications() {
    unreadNotifications = 0;
    notifyListeners();
  }

  final Set<String> acknowledged = {'Emergency escalation plan'};
  void acknowledge(String doc) {
    acknowledged.add(doc);
    notifyListeners();
  }

  String lastReportId = 'INC-1042';
}

String hhmm(DateTime t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

String mmss(Duration d) {
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  if (d.inHours > 0) return '${d.inHours}:$m:$s';
  return '$m:$s';
}

String hm(Duration d) => '${d.inHours}h ${d.inMinutes.remainder(60)}m';

class DemoScope extends InheritedNotifier<DemoState> {
  const DemoScope({super.key, required DemoState state, required super.child}) : super(notifier: state);

  static DemoState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<DemoScope>();
    assert(scope != null, 'DemoScope not found');
    return scope!.notifier!;
  }

  /// Read without subscribing (for callbacks).
  static DemoState read(BuildContext context) {
    final scope = context.getElementForInheritedWidgetOfExactType<DemoScope>()!.widget as DemoScope;
    return scope.notifier!;
  }
}
