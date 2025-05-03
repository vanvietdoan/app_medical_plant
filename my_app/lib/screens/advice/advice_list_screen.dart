import 'package:flutter/material.dart';
import '../../models/advice.dart';
import '../../models/user.dart';
import '../../services/advice_service.dart';
import '../../services/auth_service.dart';
import 'package:intl/intl.dart';

class ManageAdviceScreen extends StatefulWidget {
  final int expertId;

  const ManageAdviceScreen({
    super.key,
    required this.expertId,
  });

  @override
  State<ManageAdviceScreen> createState() => _ManageAdviceScreenState();
}

class _ManageAdviceScreenState extends State<ManageAdviceScreen> {
  final _adviceService = AdviceService();

  List<Advice> _advices = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAdvices();
  }

  Future<void> _loadAdvices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      debugPrint('expertId in manage advice screen: ${widget.expertId}');
      final advices = await _adviceService.getAdvicesByUser(widget.expertId);
      setState(() {
        _advices = advices;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _editAdvice(Advice advice) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chức năng chỉnh sửa đang được phát triển'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Future<void> _deleteAdvice(Advice advice) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa lời khuyên này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _adviceService.deleteAdvice(advice.adviceId);
        _loadAdvices();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã xóa lời khuyên thành công'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi khi xóa lời khuyên: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý lời khuyên'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadAdvices,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : _advices.isEmpty
                  ? const Center(
                      child: Text('Bạn chưa có lời khuyên nào'),
                    )
                  : ListView.builder(
                      itemCount: _advices.length,
                      itemBuilder: (context, index) {
                        final advice = _advices[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            title: Text(advice.title ?? 'Không có tiêu đề'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(advice.content ?? ''),
                                const SizedBox(height: 8),
                                Text(
                                  'Cây: ${advice.plant?.name ?? 'Không xác định'}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  'Bệnh: ${advice.disease?.name ?? 'Không xác định'}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  'Ngày tạo: ${_formatDate(advice.createdAt)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _editAdvice(advice),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _deleteAdvice(advice),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Chức năng tạo lời khuyên đang được phát triển'),
              backgroundColor: Colors.orange,
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
