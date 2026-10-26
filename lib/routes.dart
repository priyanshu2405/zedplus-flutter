import 'package:flutter/widgets.dart';

import 'screens/access.dart';
import 'screens/attendance.dart';
import 'screens/directory.dart';
import 'screens/equipment_approvals.dart';
import 'screens/home_profile.dart';
import 'screens/ops_safety.dart';
import 'screens/patrol_reports.dart';
import 'screens/schedule_briefing.dart';
import 'screens/supervisor_route.dart';

class ScreenEntry {
  const ScreenEntry(this.number, this.code, this.title, this.builder);
  final int number;
  final String code;
  final String title;
  final WidgetBuilder builder;
  String get route => '/${code.toLowerCase()}';
}

class ScreenGroup {
  const ScreenGroup(this.title, this.flow, this.screens);
  final String title;
  final String flow;
  final List<ScreenEntry> screens;
}

/// Mirrors APP_FLOW_GUIDE.txt from the design package (91 screens, 17 workflows).
final List<ScreenGroup> screenGroups = [
  ScreenGroup('01 • Access and sign in', 'Welcome > Sign in > Home. New user: Join company > Permissions > Home.', [
    ScreenEntry(1, 'M01', 'Welcome', (_) => const WelcomeScreen()),
    ScreenEntry(2, 'M02', 'Sign in', (_) => const SignInScreen()),
    ScreenEntry(3, 'M03', 'Join company', (_) => const JoinCompanyScreen()),
    ScreenEntry(4, 'M06', 'Location & permissions', (_) => const PermissionsScreen()),
    ScreenEntry(5, 'M05', 'PIN & biometric unlock', (_) => const PinUnlockScreen()),
    ScreenEntry(6, 'M04', 'Reset password', (_) => const ResetPasswordScreen()),
  ]),
  ScreenGroup('02 • Profile and setup', 'Review profile, licences, assigned sites and settings.', [
    ScreenEntry(7, 'M88', 'My profile', (_) => const ProfileScreen()),
    ScreenEntry(8, 'M89', 'Licences & certificates', (_) => const LicencesScreen()),
    ScreenEntry(9, 'M90', 'Assigned sites', (_) => const AssignedSitesScreen()),
    ScreenEntry(10, 'M91', 'App settings', (_) => const SettingsScreen()),
  ]),
  ScreenGroup('03 • Home and notifications', 'Role-specific home screens; notifications open the related task.', [
    ScreenEntry(11, 'M07', 'Guard home', (_) => const GuardHomeScreen()),
    ScreenEntry(12, 'M08', 'Supervisor home', (_) => const SupervisorHomeScreen()),
    ScreenEntry(13, 'M87', 'Notifications', (_) => const NotificationsScreen()),
  ]),
  ScreenGroup('04 • Schedule and shift requests', 'My schedule > Shift detail. Open shifts, availability, time off, swaps.', [
    ScreenEntry(14, 'M22', 'My schedule', (_) => const MyScheduleScreen()),
    ScreenEntry(15, 'M23', 'Shift detail', (_) => const ShiftDetailScreen()),
    ScreenEntry(16, 'M24', 'Open shifts', (_) => const OpenShiftsScreen()),
    ScreenEntry(17, 'M25', 'Availability', (_) => const AvailabilityScreen()),
    ScreenEntry(18, 'M26', 'Time off request', (_) => const TimeOffScreen()),
    ScreenEntry(19, 'M27', 'Shift swap', (_) => const ShiftSwapScreen()),
  ]),
  ScreenGroup('05 • Shift briefing and tasks', 'Read post orders, review passdowns, then open tasks.', [
    ScreenEntry(20, 'M52', 'Post orders & policies', (_) => const PostOrdersScreen()),
    ScreenEntry(21, 'M53', 'Post orders reader', (_) => const PostOrdersReaderScreen()),
    ScreenEntry(22, 'M54', 'Passdown log', (_) => const PassdownLogScreen()),
    ScreenEntry(23, 'M50', 'Tasks & checklists', (_) => const TasksScreen()),
    ScreenEntry(24, 'M51', 'Task detail', (_) => const TaskDetailScreen()),
  ]),
  ScreenGroup('06 • Start shift and attendance', 'GPS clock-in > Photo verification > Punch accepted > Active shift.', [
    ScreenEntry(25, 'M09', 'GPS clock-in', (_) => const GpsClockInScreen()),
    ScreenEntry(26, 'M10', 'Photo verification', (_) => const PhotoVerificationScreen()),
    ScreenEntry(27, 'M11', 'Punch accepted', (_) => const PunchAcceptedScreen()),
    ScreenEntry(28, 'M12', 'Active shift', (_) => const ActiveShiftScreen()),
    ScreenEntry(29, 'M21', 'Site check-in & check-out', (_) => const SiteCheckInScreen()),
    ScreenEntry(30, 'M16', 'Geofence punch blocked', (_) => const GeofenceBlockedScreen()),
    ScreenEntry(31, 'M17', 'Punch exception request', (_) => const PunchExceptionScreen()),
    ScreenEntry(32, 'M18', 'Offline sync queue', (_) => const OfflineSyncScreen()),
  ]),
  ScreenGroup('07 • Patrol tour', 'Tours > In progress > Scan > Questions > repeat > Summary.', [
    ScreenEntry(33, 'M37', 'Patrol tours', (_) => const PatrolToursScreen()),
    ScreenEntry(34, 'M38', 'Tour in progress', (_) => const TourInProgressScreen()),
    ScreenEntry(35, 'M39', 'Checkpoint scan', (_) => const CheckpointScanScreen()),
    ScreenEntry(36, 'M40', 'Checkpoint questions', (_) => const CheckpointQuestionsScreen()),
    ScreenEntry(37, 'M42', 'Tour summary', (_) => const TourSummaryScreen()),
    ScreenEntry(38, 'M41', 'Scan failed', (_) => const ScanFailedScreen()),
  ]),
  ScreenGroup('08 • Reports and evidence', 'Reports > Templates > Incident / Daily > Evidence > Submitted.', [
    ScreenEntry(39, 'M43', 'Reports & drafts', (_) => const ReportsScreen()),
    ScreenEntry(40, 'M44', 'Report templates', (_) => const ReportTemplatesScreen()),
    ScreenEntry(41, 'M45', 'Incident report', (_) => const IncidentReportScreen()),
    ScreenEntry(42, 'M46', 'Daily & hourly activity', (_) => const DailyActivityScreen()),
    ScreenEntry(43, 'M47', 'Report evidence', (_) => const ReportEvidenceScreen()),
    ScreenEntry(44, 'M48', 'Report submitted', (_) => const ReportSubmittedScreen()),
    ScreenEntry(45, 'M49', 'Report correction', (_) => const ReportCorrectionScreen()),
  ]),
  ScreenGroup('09 • Visitor and vehicle logs', 'Visitor log > Check-in. Vehicle log is separate.', [
    ScreenEntry(46, 'M68', 'Visitor log', (_) => const VisitorLogScreen()),
    ScreenEntry(47, 'M69', 'Visitor check-in', (_) => const VisitorCheckInScreen()),
    ScreenEntry(48, 'M70', 'Vehicle log', (_) => const VehicleLogScreen()),
  ]),
  ScreenGroup('10 • Dispatch response', 'Jobs > Detail > Response > Alarm close-out.', [
    ScreenEntry(49, 'M56', 'Dispatch jobs', (_) => const DispatchJobsScreen()),
    ScreenEntry(50, 'M57', 'Dispatch job detail', (_) => const DispatchJobDetailScreen()),
    ScreenEntry(51, 'M58', 'Dispatch response', (_) => const DispatchResponseScreen()),
    ScreenEntry(52, 'M59', 'Alarm close-out report', (_) => const AlarmCloseOutScreen()),
  ]),
  ScreenGroup('11 • Safety and emergencies', 'Safety centre > Panic alert > Panic active, plus lone-worker & fall.', [
    ScreenEntry(53, 'M60', 'Safety centre', (_) => const SafetyCentreScreen()),
    ScreenEntry(54, 'M61', 'Panic alert', (_) => const PanicAlertScreen()),
    ScreenEntry(55, 'M62', 'Panic active', (_) => const PanicActiveScreen()),
    ScreenEntry(56, 'M63', 'Lone-worker check-in', (_) => const LoneWorkerScreen()),
    ScreenEntry(57, 'M64', 'Fall alert countdown', (_) => const FallAlertScreen()),
    ScreenEntry(58, 'M67', 'Emergency contacts', (_) => const EmergencyContactsScreen()),
  ]),
  ScreenGroup('12 • Messages and passdowns', 'Messages > Dispatch chat. Create a passdown.', [
    ScreenEntry(59, 'M65', 'Messages', (_) => const MessagesScreen()),
    ScreenEntry(60, 'M66', 'Dispatch chat', (_) => const DispatchChatScreen()),
    ScreenEntry(61, 'M55', 'Create passdown', (_) => const CreatePassdownScreen()),
  ]),
  ScreenGroup('13 • Breaks and end shift', 'Break timer. GPS clock-out > Completed > Timesheet.', [
    ScreenEntry(62, 'M15', 'Break timer', (_) => const BreakTimerScreen()),
    ScreenEntry(63, 'M13', 'GPS clock-out', (_) => const GpsClockOutScreen()),
    ScreenEntry(64, 'M14', 'Shift completed', (_) => const ShiftCompletedScreen()),
    ScreenEntry(65, 'M19', 'My timesheet', (_) => const MyTimesheetScreen()),
    ScreenEntry(66, 'M20', 'Timesheet detail', (_) => const TimesheetDetailScreen()),
  ]),
  ScreenGroup('14 • Supervisor route and inspection', 'Route > Map > Stop > Navigate > Inspect > Sign-off > Summary.', [
    ScreenEntry(67, 'M28', 'Today’s supervision route', (_) => const TodayRouteScreen()),
    ScreenEntry(68, 'M29', 'Route map', (_) => const RouteMapScreen()),
    ScreenEntry(69, 'M30', 'Route stop detail', (_) => const RouteStopDetailScreen()),
    ScreenEntry(70, 'M31', 'Navigation handoff', (_) => const NavigationHandoffScreen()),
    ScreenEntry(71, 'M32', 'Site inspection', (_) => const SiteInspectionScreen()),
    ScreenEntry(72, 'M33', 'Client sign-off', (_) => const ClientSignOffScreen()),
    ScreenEntry(73, 'M35', 'Route summary', (_) => const RouteSummaryScreen()),
    ScreenEntry(74, 'M36', 'Mileage claim', (_) => const MileageClaimScreen()),
    ScreenEntry(75, 'M34', 'Skip route stop', (_) => const SkipStopScreen()),
  ]),
  ScreenGroup('15 • Equipment and assets', 'Catalogue > Request > Receipt. Keys > Scan > Stock count.', [
    ScreenEntry(76, 'M71', 'My equipment', (_) => const MyEquipmentScreen()),
    ScreenEntry(77, 'M72', 'Equipment catalogue', (_) => const EquipmentCatalogueScreen()),
    ScreenEntry(78, 'M73', 'Equipment request', (_) => const EquipmentRequestScreen()),
    ScreenEntry(79, 'M76', 'Equipment receipt', (_) => const EquipmentReceiptScreen()),
    ScreenEntry(80, 'M77', 'Site keys & assets', (_) => const SiteKeysScreen()),
    ScreenEntry(81, 'M78', 'Asset scan', (_) => const AssetScanScreen()),
    ScreenEntry(82, 'M79', 'Stock count', (_) => const StockCountScreen()),
    ScreenEntry(83, 'M74', 'Lost or damaged item', (_) => const LostDamagedScreen()),
    ScreenEntry(84, 'M75', 'Equipment return', (_) => const EquipmentReturnScreen()),
  ]),
  ScreenGroup('16 • My requests and tracking', 'My requests > Request tracking.', [
    ScreenEntry(85, 'M80', 'My requests', (_) => const MyRequestsScreen()),
    ScreenEntry(86, 'M81', 'Request tracking', (_) => const RequestTrackingScreen()),
  ]),
  ScreenGroup('17 • Supervisor approvals', 'Inbox > Detail > Approve or Reject/return > History.', [
    ScreenEntry(87, 'M82', 'Approvals inbox', (_) => const ApprovalsInboxScreen()),
    ScreenEntry(88, 'M83', 'Approval detail', (_) => const ApprovalDetailScreen()),
    ScreenEntry(89, 'M84', 'Reject or return request', (_) => const RejectReturnScreen()),
    ScreenEntry(90, 'M85', 'Delegate approvals', (_) => const DelegateApprovalsScreen()),
    ScreenEntry(91, 'M86', 'Approval history', (_) => const ApprovalHistoryScreen()),
  ]),
];

Map<String, WidgetBuilder> buildRoutes() {
  final map = <String, WidgetBuilder>{
    '/': (_) => const WelcomeScreen(),
    '/directory': (_) => const DirectoryScreen(),
  };
  for (final g in screenGroups) {
    for (final s in g.screens) {
      map[s.route] = s.builder;
    }
  }
  return map;
}
