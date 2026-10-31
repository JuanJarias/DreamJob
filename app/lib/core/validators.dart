class Validators {
  const Validators._();

  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static String? required(String? value, [String fieldName = 'Este campo']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es obligatorio';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El correo electrónico es obligatorio';
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Ingresa un correo electrónico válido';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es obligatoria';
    }
    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }
    return null;
  }

  static String? date(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La fecha de nacimiento es obligatoria';
    }
    final parsed = DateTime.tryParse(value.trim());
    if (parsed == null) {
      return 'Selecciona una fecha de nacimiento válida';
    }
    final now = DateTime.now();
    if (parsed.isAfter(now)) {
      return 'La fecha de nacimiento no puede ser futura';
    }
    return null;
  }
}
