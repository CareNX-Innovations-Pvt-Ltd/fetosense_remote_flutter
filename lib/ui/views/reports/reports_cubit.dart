import 'package:bloc/bloc.dart';
import 'package:appwrite/appwrite.dart';
import 'package:fetosense_remote_flutter/core/network/appwrite_config.dart';
import 'package:fetosense_remote_flutter/core/utils/app_constants.dart';
import 'package:fetosense_remote_flutter/locater.dart';
import 'package:fetosense_remote_flutter/ui/widgets/card_widget.dart';
import 'package:flutter/material.dart';
import 'reports_state.dart';

class ReportsCubit extends Cubit<ReportsState> {
  final Databases db;

  ReportsCubit({Databases? databases})
      : db = databases ?? Databases(locator<AppwriteService>().client),
        super(const ReportsState());

  Future<void> fetchReports() async {
    print("FETCH STARTED");
    emit(state.copyWith(status: ReportsStatus.loading));

    try {
      final orgResult = await db.listDocuments(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: AppConstants.userCollectionId,
        queries: [Query.equal('type', 'organization')],
      );
      print("ORG COUNT = ${orgResult.total}");

      final deviceResult = await db.listDocuments(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: AppConstants.deviceCollectionId,
        queries: [Query.limit(2000)],
      );
      print("DEVICE COUNT = ${deviceResult.total}");

      final mothersResult = await db.listDocuments(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: AppConstants.userCollectionId,
        queries: [Query.equal('type', 'mother')],
      );
      print("MOTHERS COUNT = ${mothersResult.total}");

      final referralResult = await db.listDocuments(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: AppConstants.testsCollectionId,
        queries: [Query.equal('referral', true)],
      );
      print("REFERRAL COUNT = ${referralResult.total}");

      final testsResult = await db.listDocuments(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: AppConstants.testsCollectionId,
      );
      print("TEST COUNT = ${testsResult.total}");

      print("EMITTING LOADED");

      emit(state.copyWith(
        status: ReportsStatus.loaded,
        organizations: orgResult.total,
        devices: deviceResult.total,
        mothers: mothersResult.total,
        tests: testsResult.total,
        referrals: referralResult.total,
      ));
    } catch (e) {
      print("ERROR OCCURRED → $e");
      emit(state.copyWith(
          status: ReportsStatus.error, errorMessage: e.toString()));
    }
  }

  List<DashboardStat> get dashboardStats => [
        DashboardStat(
          icon: Icons.business,
          title: "Organizations",
          count: state.organizations.toString(),
        ),
        DashboardStat(
          icon: Icons.devices,
          title: "Devices",
          count: state.devices.toString(),
        ),
        DashboardStat(
          icon: Icons.pregnant_woman,
          title: "Mothers",
          count: state.mothers.toString(),
        ),
        DashboardStat(
          icon: Icons.monitor_heart,
          title: "Tests",
          count: state.tests.toString(),
        ),
        DashboardStat(
          icon: Icons.account_circle_outlined,
          title: "Referrals",
          count: state.referrals.toString(),
        ),
      ];
}
