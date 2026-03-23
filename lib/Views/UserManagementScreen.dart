import 'package:flutter/material.dart';
import '../Controller/UserManagementController.dart';
import '../Models/User.dart';
import 'UserDetailScreen.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final UserManagementController _controller = UserManagementController();
  final TextEditingController _searchController = TextEditingController();

  List<User> _allUsers = [];
  List<User> _filteredUsers = [];
  bool _isLoading = true;
  String _filterStatus = 'all'; // 'all' | 'active' | 'blocked'

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    final users = await _controller.getAllUsers();
    setState(() {
      _allUsers = users;
      _applyFilter();
      _isLoading = false;
    });
  }

  void _applyFilter() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _allUsers.where((u) {
        final matchSearch = u.displayName.toLowerCase().contains(query) ||
            u.username.toLowerCase().contains(query);
        final matchStatus = _filterStatus == 'all' ||
            (_filterStatus == 'active' && u.isActive == 1) ||
            (_filterStatus == 'blocked' && u.isActive == 0);
        return matchSearch && matchStatus;
      }).toList();
    });
  }

  Future<void> _toggleBlock(User user) async {
    final isBlocking = user.isActive == 1;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              isBlocking ? Icons.block_rounded : Icons.lock_open_rounded,
              color: isBlocking ? Colors.red : Colors.green,
            ),
            const SizedBox(width: 10),
            Text(isBlocking ? 'Khóa tài khoản' : 'Mở khóa tài khoản'),
          ],
        ),
        content: Text(
          isBlocking
              ? 'Bạn có chắc muốn KHÓA tài khoản "${user.displayName}"?\n\nUser này sẽ không thể đăng nhập.'
              : 'Bạn có chắc muốn MỞ KHÓA tài khoản "${user.displayName}"?',
          style: const TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('HỦY', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isBlocking ? Colors.red : Colors.green,
              shape: const StadiumBorder(),
            ),
            child: Text(
              isBlocking ? 'KHÓA' : 'MỞ KHÓA',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    bool success = isBlocking
        ? await _controller.blockUser(user.id!)
        : await _controller.unblockUser(user.id!);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              isBlocking ? '🔒 Đã khóa tài khoản ${user.displayName}' : '🔓 Đã mở khóa ${user.displayName}'),
          backgroundColor: isBlocking ? Colors.red[700] : Colors.green[700],
          behavior: SnackBarBehavior.floating,
        ),
      );
      _loadUsers();
    }
  }

  @override
  Widget build(BuildContext context) {
    final int activeCount = _allUsers.where((u) => u.isActive == 1).length;
    final int blockedCount = _allUsers.where((u) => u.isActive == 0).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Quản lý người dùng',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[900],
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              // ── Search Bar ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => _applyFilter(),
                  style: const TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    hintText: 'Tìm theo tên hoặc username...',
                    hintStyle:
                    const TextStyle(color: Colors.white54, fontSize: 14),
                    prefixIcon:
                    const Icon(Icons.search, color: Colors.white70),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.close,
                          color: Colors.white70, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        _applyFilter();
                      },
                    )
                        : null,
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.15),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // ── Filter Chips ────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Row(
                  children: [
                    _buildFilterChip('all', 'Tất cả (${_allUsers.length})'),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                        'active', 'Active ($activeCount)', Colors.green),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                        'blocked', 'Bị khóa ($blockedCount)', Colors.red),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredUsers.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
        onRefresh: _loadUsers,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _filteredUsers.length,
          itemBuilder: (context, index) =>
              _buildUserCard(_filteredUsers[index]),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String value, String label,
      [Color color = Colors.blue]) {
    final isSelected = _filterStatus == value;
    return GestureDetector(
      onTap: () {
        setState(() => _filterStatus = value);
        _applyFilter();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? color : Colors.white70,
            fontWeight:
            isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isNotEmpty
                ? 'Không tìm thấy kết quả'
                : 'Chưa có người dùng nào',
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(User user) {
    final isBlocked = user.isActive == 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isBlocked
            ? Border.all(color: Colors.red.withOpacity(0.3), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => UserDetailScreen(
                user: user,
                onBlockChanged: _loadUsers,
              ),
            ),
          );
        },
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: isBlocked
                  ? Colors.red.withOpacity(0.1)
                  : Colors.blue.withOpacity(0.1),
              child: Text(
                user.displayName.isNotEmpty
                    ? user.displayName[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  color: isBlocked ? Colors.red : Colors.blue[900],
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            if (isBlocked)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.block,
                      color: Colors.white, size: 12),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                user.displayName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: isBlocked ? Colors.grey : Colors.black87,
                ),
              ),
            ),
            if (isBlocked)
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Bị khóa',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              const Icon(Icons.person_outline, size: 12, color: Colors.grey),
              const SizedBox(width: 4),
              Text('@${user.username}',
                  style:
                  const TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(width: 12),
              const Icon(Icons.local_fire_department,
                  size: 12, color: Colors.orangeAccent),
              const SizedBox(width: 4),
              Text('${user.streakCount} ngày',
                  style: const TextStyle(
                      color: Colors.orangeAccent, fontSize: 12)),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Nút block/unblock
            GestureDetector(
              onTap: () => _toggleBlock(user),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isBlocked
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isBlocked
                      ? Icons.lock_open_rounded
                      : Icons.block_rounded,
                  color: isBlocked ? Colors.green : Colors.red,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios,
                size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}