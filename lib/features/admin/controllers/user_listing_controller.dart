import 'package:are_mart/models/user_model.dart';
import 'package:are_mart/utils/logging/logger.dart';
import 'package:are_mart/utils/popups/loaders.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class UserListingController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observable variables
  RxList<UserModel> allUsers = <UserModel>[].obs;
  // RxList<UserModel> users = <UserModel>[].obs;
  RxList<UserModel> filteredUsers = <UserModel>[].obs;
  RxBool isLoading = false.obs;
  RxString searchQuery = ''.obs;

  // Pagination
  DocumentSnapshot? lastDocument;
  final int paginationLimit = 15;
  RxBool allUsersLoaded = false.obs;

  // Roles
  final List<String> userRoles = ['user', 'admin', 'delivery partner'];

  // Status options
  final List<String> statusOptions = ['active', 'inactive', 'suspended'];

  // Search mode
  RxBool isSearchMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUsers();

    // Listen to search query changes
    debounce(searchQuery, (_) {
      if (searchQuery.value.isEmpty) {
        resetSearch();
      } else {
        isSearchMode.value = true;
        searchUsers(searchQuery.value);
      }
    }, time: Duration(milliseconds: 500));
  }

  // Fetch initial users
  Future<void> fetchUsers() async {
    TLoggerHelper.customPrint("calling fetchUsers");
    // isLoading.value = true;
    // users.clear();
    allUsers.clear();
    filteredUsers.clear();
    lastDocument = null;
    allUsersLoaded.value = false;

    try {
      await loadMoreUsers();
    } catch (e) {
      TLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to fetch users: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Load more users (pagination)
  Future<void> loadMoreUsers() async {
    // Don't load more if we're in search mode
    if (isLoading.value || allUsersLoaded.value || isSearchMode.value) return;

    TLoggerHelper.customPrint("calling load more users");

    isLoading.value = true;

    try {
      Query query = _firestore
          .collection('users')
          .orderBy('createdAt', descending: true)
          .limit(paginationLimit);

      // Add startAfter if we have a last document
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument!);
      }

      QuerySnapshot querySnapshot = await query.get();

      if (querySnapshot.docs.isEmpty) {
        allUsersLoaded.value = true;
      } else {
        lastDocument = querySnapshot.docs.last;

        final newUsers =
            querySnapshot.docs.map((doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              if (!data.containsKey('userId')) {
                data['userId'] = doc.id;
                TLoggerHelper.customPrint(data);
              }
              TLoggerHelper.customPrint(data);
              return UserModel.fromJson(data);
            }).toList();

        // users.addAll(newUsers);
        allUsers.addAll(newUsers);

        // If not in search mode, update filtered users
        if (!isSearchMode.value) {
          filteredUsers.value = allUsers;
        }
      }
    } catch (e) {
      TLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to load more users: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Server-side search for users
  Future<void> searchUsers(String query) async {
    if (query.isEmpty) return;

    // TLoggerHelper.customPrint(users);

    isLoading.value = true;
    filteredUsers.clear();

    try {
      // Handle phone number search
      QuerySnapshot phoneQuerySnapshot =
          await _firestore
              .collection('users')
              .orderBy('number')
              .startAt([query])
              .endAt([query + '\uf8ff'])
              .limit(paginationLimit)
              .get();

      // Combine results (removing duplicates)
      Set<String> addedIds = {};
      List<UserModel> searchResults = [];

      // Process phone results
      for (var doc in phoneQuerySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (!data.containsKey('userId')) {
          data['userId'] = doc.id;
        }
        // TLoggerHelper.customPrint(data);
        if (!addedIds.contains(doc.id)) {
          addedIds.add(doc.id);
          searchResults.add(UserModel.fromJson(data));
        }
      }

      filteredUsers.value = searchResults;

      if (filteredUsers.isEmpty) {
        TLoaders.errorSnackBar(
          title: 'No Results',
          message: 'No users found matching "$query"',
        );
      }
    } catch (e) {
      TLoaders.errorSnackBar(
        title: 'Search Error',
        message: 'Failed to search users: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Load more search results
  // Future<void> loadMoreSearchResults() async {
  //   if (!isSearchMode.value || isLoading.value) return;

  //   // This is a placeholder for implementing pagination for search results
  //   // You'd need to track lastSearchDocument for each query type and implement pagination
  //   TLoaders.errorSnackBar(
  //     title: 'Info',
  //     message: 'Loading more search results not implemented yet',
  //   );
  // }

  // Reset search
  void resetSearch() {
    searchQuery.value = '';
    isSearchMode.value = false;
    // filteredUsers.value = users;
    filteredUsers.value = allUsers;
  }

  // Update user role
  Future<void> updateUserRole(String userId, String newRole) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'role': newRole,
      });

      // Update local data
      final index = allUsers.indexWhere((user) => user.userId == userId);
      if (index != -1) {
        final updatedUser = UserModel(
          address: allUsers[index].address,
          name: allUsers[index].name,
          number: allUsers[index].number,
          role: newRole,
          userId: allUsers[index].userId,
          status: allUsers[index].status,
        );
        // users[index] = updatedUser;
        allUsers[index] = updatedUser;

        // Also update in filtered list if present
        final filteredIndex = filteredUsers.indexWhere(
          (user) => user.userId == userId,
        );
        if (filteredIndex != -1) {
          filteredUsers[filteredIndex] = updatedUser;
        }
      }

      TLoaders.successSnackBar(
        title: 'Success',
        message: 'User role updated successfully',
      );
    } catch (e) {
      TLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to update user role: $e',
      );
    }
  }

  // Update user status
  Future<void> updateUserStatus(String userId, String newStatus) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'status': newStatus,
      });

      // Update local data
      final index = allUsers.indexWhere((user) => user.userId == userId);
      if (index != -1) {
        final updatedUser = UserModel(
          address: allUsers[index].address,
          name: allUsers[index].name,
          number: allUsers[index].number,
          role: allUsers[index].role,
          userId: allUsers[index].userId,
          status: newStatus,
        );
        // users[index] = updatedUser;
        allUsers[index] = updatedUser;

        // Also update in filtered list if present
        final filteredIndex = filteredUsers.indexWhere(
          (user) => user.userId == userId,
        );
        if (filteredIndex != -1) {
          filteredUsers[filteredIndex] = updatedUser;
        }
      }

      TLoaders.successSnackBar(
        title: 'Success',
        message: 'User status updated successfully',
      );
    } catch (e) {
      TLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to update user status: $e',
      );
    }
  }
}
