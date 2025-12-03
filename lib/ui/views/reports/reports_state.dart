import 'package:equatable/equatable.dart';

enum ReportsStatus { initial, loading, loaded, error }

class ReportsState extends Equatable {
  final ReportsStatus status;
  final int organizations;
  final int devices;
  final int mothers;
  final int tests;
  final int referrals;
  final String? errorMessage;

  const ReportsState({
    this.status = ReportsStatus.initial,
    this.organizations = 0,
    this.devices = 0,
    this.mothers = 0,
    this.tests = 0,
    this.referrals = 0,
    this.errorMessage,
  });

  ReportsState copyWith({
    ReportsStatus? status,
    int? organizations,
    int? devices,
    int? mothers,
    int? tests,
    int? referrals,
    String? errorMessage,
  }) {
    return ReportsState(
      status: status ?? this.status,
      organizations: organizations ?? this.organizations,
      devices: devices ?? this.devices,
      mothers: mothers ?? this.mothers,
      tests: tests ?? this.tests,
      referrals: referrals ?? this.referrals,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, organizations, devices, mothers, tests, referrals,errorMessage];
}
