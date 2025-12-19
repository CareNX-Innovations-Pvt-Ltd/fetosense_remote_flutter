import 'package:bloc/bloc.dart';
import 'package:appwrite/appwrite.dart';
import 'package:fetosense_remote_flutter/core/network/appwrite_config.dart';
import 'package:fetosense_remote_flutter/core/utils/app_constants.dart';
import 'package:fetosense_remote_flutter/locater.dart';
import 'package:fetosense_remote_flutter/ui/widgets/card_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'reports_state.dart';

class ReportsCubit extends Cubit<ReportsState> {
  final Databases db;

  ReportsCubit({Databases? databases})
      : db = databases ?? Databases(locator<AppwriteService>().client),
        super(const ReportsState());

  Future<void> fetchReports() async {
    emit(state.copyWith(status: ReportsStatus.loading));

    try {
      final orgResult = await db.listDocuments(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: AppConstants.userCollectionId,
        queries: [Query.equal('type', 'organization')],
      );

      final deviceResult = await db.listDocuments(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: AppConstants.deviceCollectionId,
        queries: [Query.limit(2000)],
      );

      final mothersResult = await db.listDocuments(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: AppConstants.userCollectionId,
        queries: [Query.equal('type', 'mother')],
      );

      final referralResult = await db.listDocuments(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: AppConstants.testsCollectionId,
        queries: [Query.equal('referral', true)],
      );

      final testsResult = await db.listDocuments(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: AppConstants.testsCollectionId,
      );

      emit(state.copyWith(
        status: ReportsStatus.loaded,
        organizations: orgResult.total,
        devices: deviceResult.total,
        mothers: mothersResult.total,
        tests: testsResult.total,
        referrals: referralResult.total,
      ));
    } catch (e) {
      emit(state.copyWith(
          status: ReportsStatus.error, errorMessage: e.toString()));
    }
  }

  List<DashboardStat> get dashboardStats => [
        DashboardStat(
          icon: Icon(Icons.business, size: 30,),
          title: "Organizations",
          count: state.organizations.toString(),
        ),
        DashboardStat(
          icon: FaIcon(FontAwesomeIcons.userDoctor, size: 30,),
          title: "Doctors",
          count: '30',
        ),
        DashboardStat(
          icon: Icon(Icons.pregnant_woman, size: 30,),
          title: "Mothers",
          count: state.mothers.toString(),
        ),
        DashboardStat(
          icon: Icon(Icons.devices, size: 30,),
          title: "Devices",
          count: state.devices.toString(),
        ),
        DashboardStat(
          icon: Icon(Icons.monitor_heart, size: 30,),
          title: "Tests",
          count: state.tests.toString(),
        ),
        DashboardStat(
          icon: FaIcon(FontAwesomeIcons.arrowsDownToPeople, size: 30,),
          title: "Referrals",
          count: state.referrals.toString(),
        ),
      ];
}
