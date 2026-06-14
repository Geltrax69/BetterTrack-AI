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

  // ── Auth ── returns {token, name, email}
  Future<Map<String, dynamic>> signup(
      {required String name, required String email, required String password}) async {
    final raw = await _api.post('/auth/signup',
        body: {'name': name, 'email': email, 'password': password});
    return raw as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> login(
      {required String email, required String password}) async {
    final raw = await _api
        .post('/auth/login', body: {'email': email, 'password': password});
    return raw as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> googleLogin(
      {required String email, required String name}) async {
    final raw = await _api
        .post('/auth/google', body: {'email': email, 'name': name});
    return raw as Map<String, dynamic>;
  }

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

  Future<Group> createGroup({
    required String name,
    List<String> members = const [],
    String currency = '₹',
  }) async {
    final raw = await _api.post('/groups', body: {
      'name': name,
      'members': members,
      'currency': currency,
    });
    return Group.fromJson(raw as Map<String, dynamic>);
  }

  Future<Group> joinGroup({required String code, String memberName = 'You'}) async {
    final raw = await _api.post('/groups/join', body: {
      'code': code.trim().toUpperCase(),
      'member_name': memberName,
    });
    return Group.fromJson(raw as Map<String, dynamic>);
  }

  Future<String> aiChat(String message, {String? groupId}) async {
    // The model can take a while; give it room before timing out.
    final raw = await _api.post('/ai/chat',
        body: {'message': message, 'group_id': groupId},
        timeout: const Duration(seconds: 60));
    return (raw as Map<String, dynamic>)['reply'] as String? ?? '';
  }
}
