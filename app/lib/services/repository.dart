import '../models/models.dart';
import 'api_client.dart';

/// Typed access to the backend. Each method returns domain models and throws
/// [ApiException] on failure (handled by the screens' AsyncValue lifecycle).
class Repository {
  Repository({ApiClient? client}) : _api = client ?? ApiClient();
  final ApiClient _api;

  /// Global instance used by screens. Mutable so tests can inject a fake
  /// (e.g. backed by a MockClient) without reaching the network.
  static Repository instance = Repository();

  List<Map<String, dynamic>> _list(dynamic raw) =>
      (raw as List).cast<Map<String, dynamic>>();

  Future<Summary> summary() async =>
      Summary.fromJson(await _api.get('/summary') as Map<String, dynamic>);

  Future<List<Budget>> budgets() async =>
      _list(await _api.get('/budgets')).map(Budget.fromJson).toList();

  Future<List<Activity>> activity() async =>
      _list(await _api.get('/activity')).map(Activity.fromJson).toList();

  Future<List<Group>> groups() async =>
      _list(await _api.get('/groups')).map(Group.fromJson).toList();

  Future<List<Expense>> expenses({String? groupId}) async {
    final path = groupId == null ? '/expenses' : '/expenses?group_id=$groupId';
    return _list(await _api.get(path)).map(Expense.fromJson).toList();
  }

  Future<Expense> createExpense({
    required String name,
    required String category,
    required double amount,
    required String payer,
    String? groupId,
  }) async {
    final raw = await _api.post('/expenses', body: {
      'name': name,
      'category': category,
      'amount': amount,
      'payer': payer,
      'group_id': groupId,
    });
    return Expense.fromJson(raw as Map<String, dynamic>);
  }

  Future<String> aiChat(String message, {String? groupId}) async {
    final raw = await _api.post('/ai/chat',
        body: {'message': message, 'group_id': groupId});
    return (raw as Map<String, dynamic>)['reply'] as String? ?? '';
  }
}
