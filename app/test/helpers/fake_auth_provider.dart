import 'package:dreamjob/auth/data/auth_repository.dart';
import 'package:dreamjob/auth/data/models.dart';
import 'package:dreamjob/auth/state/auth_provider.dart';
import '../fakes/fake_auth_repository.dart';

class FakeAuthProvider extends AuthProvider {
  FakeAuthProvider({AuthRepository? repository})
      : super(repository: repository ?? FakeAuthRepository());

  UserRole? _customRole;
  CandidateProfile? _customCandidate;
  RecruiterProfile? _customRecruiter;
  bool _customLoading = false;
  String? _customError;

  bool signUpRecruiterCalled = false;
  int signUpRecruiterCallCount = 0;
  Map<String, dynamic>? lastSignUpRecruiterArgs;

  bool signUpCandidateCalled = false;
  int signUpCandidateCallCount = 0;
  Map<String, dynamic>? lastSignUpCandidateArgs;

  bool signOutCalled = false;

  void setCandidate({
    required String nombre,
    required String email,
    required String ciudad,
    DateTime? fechaNacimiento,
    String? resumenPerfil,
  }) {
    _customRole = UserRole.candidato;
    _customCandidate = CandidateProfile(
      id: 'fake-cand-1',
      nombre: nombre,
      email: email,
      ciudad: ciudad,
      fechaNacimiento: fechaNacimiento ?? DateTime(2000, 5, 15),
      resumenPerfil: resumenPerfil,
    );
    _customRecruiter = null;
    notifyListeners();
  }

  void setRecruiter({
    required String nombre,
    required String email,
    required String empresaNombre,
    required String empresaDescripcion,
    required String empresaMonograma,
  }) {
    _customRole = UserRole.reclutador;
    _customRecruiter = RecruiterProfile(
      id: 'fake-rec-1',
      nombre: nombre,
      email: email,
      empresa: CompanyProfile(
        id: 'fake-emp-1',
        nombre: empresaNombre,
        descripcion: empresaDescripcion,
        monograma: empresaMonograma,
      ),
    );
    _customCandidate = null;
    notifyListeners();
  }

  void setRole(UserRole? role) {
    _customRole = role;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _customLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _customError = error;
    notifyListeners();
  }

  @override
  bool get loading => _customLoading;

  @override
  String? get error => _customError;

  @override
  UserRole? get role => _customRole ?? super.role;

  @override
  CandidateProfile? get candidate => _customCandidate ?? super.candidate;

  @override
  RecruiterProfile? get recruiter => _customRecruiter ?? super.recruiter;

  @override
  bool get isAuthenticated => role != null;

  @override
  Future<bool> signUpRecruiter({
    required String nombre,
    required String email,
    required String password,
    required String empresaNombre,
    required String empresaDescripcion,
    required String empresaMonograma,
  }) async {
    signUpRecruiterCalled = true;
    signUpRecruiterCallCount++;
    lastSignUpRecruiterArgs = {
      'nombre': nombre,
      'email': email,
      'password': password,
      'empresaNombre': empresaNombre,
      'empresaDescripcion': empresaDescripcion,
      'empresaMonograma': empresaMonograma,
    };
    return true;
  }

  @override
  Future<bool> signUpCandidate({
    required String nombre,
    required String email,
    required String password,
    required String ciudad,
    required DateTime fechaNacimiento,
    String? resumenPerfil,
  }) async {
    signUpCandidateCalled = true;
    signUpCandidateCallCount++;
    lastSignUpCandidateArgs = {
      'nombre': nombre,
      'email': email,
      'password': password,
      'ciudad': ciudad,
      'fechaNacimiento': fechaNacimiento,
      'resumenPerfil': resumenPerfil,
    };
    return true;
  }

  @override
  Future<void> signOut() async {
    signOutCalled = true;
    _customRole = null;
    _customCandidate = null;
    _customRecruiter = null;
    await super.signOut();
  }
}
