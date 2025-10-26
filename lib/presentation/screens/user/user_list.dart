part of '../screens.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({Key? key}) : super(key: key);

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<UserModel> users = [];
  bool isLoading = true;
  UserModel? currentUser;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => isLoading = true);
    
    final userList = await LocaleApi.getUserList();
    final current = await LocaleApi.getUser();
    
    setState(() {
      users = userList;
      currentUser = current;
      isLoading = false;
    });
  }

  Future<void> _switchUser(UserModel user) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: kColorPrimary),
      ),
    );

    final success = await LocaleApi.switchUser(user);
    
    if (mounted) {
      Navigator.pop(context); // Close loading dialog
      
      if (success) {
        // Trigger auth bloc to reload user
        context.read<AuthBloc>().add(AuthGetUser());
        
        showSoftToast(
          context,
          'Success',
          'Switched to ${user.userInfo?.username ?? 'user'}',
        );
        
        // Navigate to data loader screen which will load all categories
        Get.offAllNamed(screenDataLoader);
      } else {
        showWarningToast(
          context,
          'Error',
          'Failed to switch user',
        );
      }
    }
  }

  Future<void> _deleteUser(UserModel user) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kColorBackDark,
        title: const Text(
          'Delete User',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to delete ${user.userInfo?.username ?? 'this user'}?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await LocaleApi.removeUserFromList(user);
      
      if (success) {
        showSoftToast(
          context,
          'Success',
          'User deleted successfully',
        );
        _loadUsers(); // Reload the list
      } else {
        showWarningToast(
          context,
          'Error',
          'Failed to delete user',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isPhone = getSize(context).width < 600;
    final bool isTablet = getSize(context).width >= 600 && getSize(context).width < 1024;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: kDecorBackground,
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.all(isPhone ? 4.w : 2.w),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Get.back(),
                      iconSize: isPhone ? 6.w : 3.w,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Saved Users',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isPhone ? 20.sp : 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    // Add new user button
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<AuthBloc>().add(AuthLogOut());
                        Get.offAllNamed(screenMenu);
                      },
                      icon: Icon(
                        Icons.add,
                        size: isPhone ? 5.w : 2.5.w,
                      ),
                      label: Text(
                        'Add User',
                        style: TextStyle(fontSize: isPhone ? 14.sp : 11.sp),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kColorPrimary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: isPhone ? 4.w : 2.w,
                          vertical: isPhone ? 1.5.h : 1.h,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // User list
              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: kColorPrimary),
                      )
                    : users.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  FontAwesomeIcons.users,
                                  size: isPhone ? 20.w : 10.w,
                                  color: Colors.white30,
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  'No saved users',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: isPhone ? 16.sp : 12.sp,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.symmetric(
                              horizontal: isPhone ? 4.w : 10.w,
                              vertical: 2.h,
                            ),
                            itemCount: users.length,
                            itemBuilder: (context, index) {
                              final user = users[index];
                              final isCurrentUser = 
                                currentUser?.userInfo?.username == user.userInfo?.username &&
                                currentUser?.serverInfo?.serverUrl == user.serverInfo?.serverUrl;

                              return Container(
                                margin: EdgeInsets.only(bottom: 2.h),
                                decoration: BoxDecoration(
                                  color: isCurrentUser 
                                      ? kColorPrimary.withOpacity(0.2)
                                      : Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isCurrentUser 
                                        ? kColorPrimary
                                        : Colors.white.withOpacity(0.1),
                                    width: isCurrentUser ? 2 : 1,
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: isPhone ? 4.w : 2.w,
                                    vertical: isPhone ? 1.h : 0.5.h,
                                  ),
                                  leading: Container(
                                    width: isPhone ? 12.w : 6.w,
                                    height: isPhone ? 12.w : 6.w,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isCurrentUser 
                                          ? kColorPrimary
                                          : const Color(0xFF6B2F8E),
                                    ),
                                    child: Center(
                                      child: Text(
                                        (user.userInfo?.username ?? 'U')
                                            .substring(0, 1)
                                            .toUpperCase(),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: isPhone ? 16.sp : 12.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    user.userInfo?.username ?? 'Unknown',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isPhone ? 16.sp : 12.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(height: 0.5.h),
                                      Text(
                                        user.serverInfo?.serverUrl ?? 'No server',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: isPhone ? 12.sp : 10.sp,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (user.userInfo?.expDate != null) ...[
                                        SizedBox(height: 0.3.h),
                                        Text(
                                          'Expires: ${_formatDate(user.userInfo!.expDate!)}',
                                          style: TextStyle(
                                            color: Colors.white60,
                                            fontSize: isPhone ? 11.sp : 9.sp,
                                          ),
                                        ),
                                      ],
                                      if (isCurrentUser) ...[
                                        SizedBox(height: 0.5.h),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 2.w,
                                            vertical: 0.3.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: kColorPrimary,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            'CURRENT',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: isPhone ? 10.sp : 8.sp,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (!isCurrentUser)
                                        IconButton(
                                          icon: Icon(
                                            Icons.login,
                                            color: kColorPrimary,
                                            size: isPhone ? 6.w : 3.w,
                                          ),
                                          onPressed: () => _switchUser(user),
                                          tooltip: 'Switch to this user',
                                        ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete_outline,
                                          color: Colors.red.shade400,
                                          size: isPhone ? 6.w : 3.w,
                                        ),
                                        onPressed: () => _deleteUser(user),
                                        tooltip: 'Delete user',
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String timestamp) {
    try {
      final date = DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp) * 1000);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return timestamp;
    }
  }
}

