
import 'dart:convert';
import 'dart:developer';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mepco_esafety_app/constants/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mepco_esafety_app/constants/storage_keys.dart';
import 'package:mepco_esafety_app/utils/snackbar_helper.dart';

class PtwListController extends GetxController {
  var isLoading = true.obs; // First load shimmer
  var ptwList = <Map<String, dynamic>>[].obs;
  var currentUserRole = ''.obs;

  var hasMore = true.obs; // Pagination flag
  var selectedStatus = ''.obs;
  var fromDate = ''.obs;
  var toDate = ''.obs;
  var searchQuery = ''.obs;

  late TextEditingController searchController;
  var sortBy = 'updated_at'.obs;
  var sortDir = 'desc'.obs;

  var page = 1.obs;
  var perPage = 10.obs; // Items per page
  Timer? searchDebounce;

  var initialMode = true.obs;
  ScrollController scrollController = ScrollController();
  var isFetching = false.obs; // Bottom loader flag

  @override
  void onInit() {
    searchController = TextEditingController();
    super.onInit();
    _loadUserRole();
    initScrollListener();
    //fetchPtwList();
  }

  @override
  void onClose() {
    searchController.dispose();
    searchDebounce?.cancel();
    scrollController.dispose();
    super.onClose();
  }
  @override
  void onReady() {
    super.onReady();
    fetchPtwList();
  }
  // void initScrollListener() {
  //   scrollController.addListener(() {
  //     if (scrollController.position.pixels >=
  //         scrollController.position.maxScrollExtent - 250) {
  //       if (isFetching.value || !hasMore.value) return;
  //
  //       isFetching.value = true;
  //       page.value++;
  //       fetchPtwList(loadMore: true);
  //     }
  //   });
  // }
  void initScrollListener() {
    scrollController.addListener(() {
      // ✅ hasClients check is redundant in listener but doesn't hurt
      if (scrollController.hasClients &&
          scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 250) {
        if (isFetching.value || !hasMore.value) return;

        isFetching.value = true;
        page.value++;
        fetchPtwList(loadMore: true);
      }
    });
  }
  Future<void> _loadUserRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString(StorageKeys.userData);

      if (userDataString != null) {
        final userData = jsonDecode(userDataString);
        dynamic roleData = userData['role'] ?? userData['roles'];
        String role;

        if (roleData is List && roleData.isNotEmpty) {
          role = roleData.first.toString();
        } else if (roleData is String) {
          role = roleData;
        } else {
          role = 'LS';
        }
        currentUserRole.value = role.toUpperCase();
      } else {
        currentUserRole.value = 'LS';
      }
    } catch (e, st) {
      currentUserRole.value = 'LS';
      log('Error loading user role: $e', stackTrace: st);
    }
  }

  Future<void> fetchPtwList({bool loadMore = false}) async {
    try {
      if (loadMore) {
        isFetching.value = true; // Bottom loader
      } else {
        page.value = 1;
        ptwList.clear();      // Clear old UI for shimmer
        isLoading.value = true;
        hasMore.value = true; // Allow more pages
      }

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(StorageKeys.authToken);

      if (token == null) {
        SnackbarHelper.showError(
            title: 'Error', message: 'Authentication Token not found.');
        return;
      }

      final uri = Uri.https('mepco.myflexihr.com', '/api/v1/ptw', {
        if (selectedStatus.value.isNotEmpty) 'status': selectedStatus.value,
        if (fromDate.value.isNotEmpty) 'from_date': fromDate.value,
        if (toDate.value.isNotEmpty) 'to_date': toDate.value,
        if (searchQuery.value.isNotEmpty) 'search': searchQuery.value,
        'page': page.value.toString(),
        'per_page': perPage.value.toString(),
      });
      // final uri = Uri.https('dev.mepco.myflexihr.com', '/api/v1/ptw', {
      //   if (selectedStatus.value.isNotEmpty) 'status': selectedStatus.value,
      //   if (fromDate.value.isNotEmpty) 'from_date': fromDate.value,
      //   if (toDate.value.isNotEmpty) 'to_date': toDate.value,
      //   if (searchQuery.value.isNotEmpty) 'search': searchQuery.value,
      //   'page': page.value.toString(),
      //   'per_page': perPage.value.toString(),
      // });

      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final List<Map<String, dynamic>> list =
        List<Map<String, dynamic>>.from(responseData['data']['data']);

        final data = responseData['data'];
        final currentPage = data['current_page'];
        final lastPage = data['last_page'];
        hasMore.value = currentPage < lastPage;
        if (loadMore) {
          ptwList.addAll(list);
        } else {
          ptwList.value = list;
        }

        // Auto load next page if list doesn't fill screen
    //     Future.delayed(Duration(milliseconds: 200), () {
    //       if (scrollController.position.maxScrollExtent <= 0 &&
    //           hasMore.value &&
    //           !isFetching.value) {
    //         page.value++;
    //         isFetching.value = true;
    //         fetchPtwList(loadMore: true);
    //       }
    //     });
    //   }
    // } finally {
    //   isLoading.value = false;
    //   isFetching.value = false;
    // }
        // ✅ Added hasClients check
        Future.delayed(Duration(milliseconds: 200), () {
          if (scrollController.hasClients &&
              scrollController.position.maxScrollExtent <= 0 &&
              hasMore.value &&
              !isFetching.value) {
            page.value++;
            isFetching.value = true;
            fetchPtwList(loadMore: true);
          }
        });
      }
    } finally {
      isLoading.value = false;
      isFetching.value = false;
    }
  }

  void clearFilters() {
    selectedStatus.value = '';
    searchQuery.value = '';
    searchController.clear();
    fromDate.value = '';
    toDate.value = '';
    initialMode.value = true;
    page.value = 1;
    fetchPtwList();
  }

  void applyFilters({String? status, String? from, String? to}) {
    if (status != null) selectedStatus.value = status;
    if (from != null) fromDate.value = from;
    if (to != null) toDate.value = to;
    page.value = 1;
    fetchPtwList();
  }

  Future<void> startPtwExecution(int ptwId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(StorageKeys.authToken);

      if (token == null) {
        SnackbarHelper.showError(
            title: 'Error', message: 'Authentication Token not found.');
        return;
      }

      final uri = Uri.parse(
          '${ApiConstants.baseUrl}/api/v1/ptw/$ptwId/start-execution');

      final response = await http.patch(uri, headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      if (response.statusCode == 200) {
        SnackbarHelper.showSuccess(
            title: 'Success', message: 'PTW execution started.');
        fetchPtwList();
      }
    } catch (e) {
      log('Error starting PTW execution: $e');
    }
  }
}
