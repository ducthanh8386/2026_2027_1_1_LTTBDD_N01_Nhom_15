class User {
  final int? id;
  final String name;
  final String email;
  final String passwordHash;
  final String salt;
  final double? heightCm;
  final double? weightKg;
  final int? age;
  final String? gender; // 'male', 'female'
  final String? goal; // 'lose_fat', 'build_muscle', 'maintain'
  final int? kcalTarget;
  final String createdAt; // ISO 8601 string

  const User({
    this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.salt,
    this.heightCm,
    this.weightKg,
    this.age,
    this.gender,
    this.goal,
    this.kcalTarget,
    required this.createdAt,
  });

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? passwordHash,
    String? salt,
    double? heightCm,
    double? weightKg,
    int? age,
    String? gender,
    String? goal,
    int? kcalTarget,
    String? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      salt: salt ?? this.salt,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      goal: goal ?? this.goal,
      kcalTarget: kcalTarget ?? this.kcalTarget,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'email': email,
      'password_hash': passwordHash,
      'salt': salt,
      'height_cm': heightCm,
      'weight_kg': weightKg,
      'age': age,
      'gender': gender,
      'goal': goal,
      'kcal_target': kcalTarget,
      'created_at': createdAt,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      passwordHash: map['password_hash'] as String? ?? '',
      salt: map['salt'] as String? ?? '',
      heightCm: (map['height_cm'] as num?)?.toDouble(),
      weightKg: (map['weight_kg'] as num?)?.toDouble(),
      age: map['age'] as int?,
      gender: map['gender'] as String?,
      goal: map['goal'] as String?,
      kcalTarget: map['kcal_target'] as int?,
      createdAt: map['created_at'] as String? ?? '',
    );
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, goal: $goal, kcalTarget: $kcalTarget)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User &&
        other.id == id &&
        other.name == name &&
        other.email == email &&
        other.passwordHash == passwordHash &&
        other.salt == salt &&
        other.heightCm == heightCm &&
        other.weightKg == weightKg &&
        other.age == age &&
        other.gender == gender &&
        other.goal == goal &&
        other.kcalTarget == kcalTarget &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      email,
      passwordHash,
      salt,
      heightCm,
      weightKg,
      age,
      gender,
      goal,
      kcalTarget,
      createdAt,
    );
  }
}
