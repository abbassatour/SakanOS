// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ClientsTable extends Clients with TableInfo<$ClientsTable, Client> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClientsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v7(),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 2,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nationalIdMeta = const VerificationMeta(
    'nationalId',
  );
  @override
  late final GeneratedColumn<String> nationalId = GeneratedColumn<String>(
    'national_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    phone,
    nationalId,
    userId,
    createdAt,
    updatedAt,
    isDeleted,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'clients';
  @override
  VerificationContext validateIntegrity(
    Insertable<Client> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    } else if (isInserting) {
      context.missing(_phoneMeta);
    }
    if (data.containsKey('national_id')) {
      context.handle(
        _nationalIdMeta,
        nationalId.isAcceptableOrUnknown(data['national_id']!, _nationalIdMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Client map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Client(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      )!,
      nationalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}national_id'],
      ),
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  $ClientsTable createAlias(String alias) {
    return $ClientsTable(attachedDatabase, alias);
  }
}

class Client extends DataClass implements Insertable<Client> {
  final String id;
  final String name;
  final String phone;
  final String? nationalId;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final bool isSynced;
  const Client({
    required this.id,
    required this.name,
    required this.phone,
    this.nationalId,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['phone'] = Variable<String>(phone);
    if (!nullToAbsent || nationalId != null) {
      map['national_id'] = Variable<String>(nationalId);
    }
    map['user_id'] = Variable<String>(userId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  ClientsCompanion toCompanion(bool nullToAbsent) {
    return ClientsCompanion(
      id: Value(id),
      name: Value(name),
      phone: Value(phone),
      nationalId: nationalId == null && nullToAbsent
          ? const Value.absent()
          : Value(nationalId),
      userId: Value(userId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      isSynced: Value(isSynced),
    );
  }

  factory Client.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Client(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String>(json['phone']),
      nationalId: serializer.fromJson<String?>(json['nationalId']),
      userId: serializer.fromJson<String>(json['userId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String>(phone),
      'nationalId': serializer.toJson<String?>(nationalId),
      'userId': serializer.toJson<String>(userId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  Client copyWith({
    String? id,
    String? name,
    String? phone,
    Value<String?> nationalId = const Value.absent(),
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    bool? isSynced,
  }) => Client(
    id: id ?? this.id,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    nationalId: nationalId.present ? nationalId.value : this.nationalId,
    userId: userId ?? this.userId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
    isSynced: isSynced ?? this.isSynced,
  );
  Client copyWithCompanion(ClientsCompanion data) {
    return Client(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      nationalId: data.nationalId.present
          ? data.nationalId.value
          : this.nationalId,
      userId: data.userId.present ? data.userId.value : this.userId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Client(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('nationalId: $nationalId, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    phone,
    nationalId,
    userId,
    createdAt,
    updatedAt,
    isDeleted,
    isSynced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Client &&
          other.id == this.id &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.nationalId == this.nationalId &&
          other.userId == this.userId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.isSynced == this.isSynced);
}

class ClientsCompanion extends UpdateCompanion<Client> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> phone;
  final Value<String?> nationalId;
  final Value<String> userId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<bool> isSynced;
  final Value<int> rowid;
  const ClientsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.nationalId = const Value.absent(),
    this.userId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ClientsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String phone,
    this.nationalId = const Value.absent(),
    required String userId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : name = Value(name),
       phone = Value(phone),
       userId = Value(userId);
  static Insertable<Client> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? nationalId,
    Expression<String>? userId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<bool>? isSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (nationalId != null) 'national_id': nationalId,
      if (userId != null) 'user_id': userId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isSynced != null) 'is_synced': isSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ClientsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? phone,
    Value<String?>? nationalId,
    Value<String>? userId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isDeleted,
    Value<bool>? isSynced,
    Value<int>? rowid,
  }) {
    return ClientsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      nationalId: nationalId ?? this.nationalId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      isSynced: isSynced ?? this.isSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (nationalId.present) {
      map['national_id'] = Variable<String>(nationalId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClientsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('nationalId: $nationalId, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isSynced: $isSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BuildingsTable extends Buildings
    with TableInfo<$BuildingsTable, Building> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BuildingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v7(),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _floorCoefficientsMeta = const VerificationMeta(
    'floorCoefficients',
  );
  @override
  late final GeneratedColumn<String> floorCoefficients =
      GeneratedColumn<String>(
        'floor_coefficients',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('{}'),
      );
  static const VerificationMeta _directionCoefficientsMeta =
      const VerificationMeta('directionCoefficients');
  @override
  late final GeneratedColumn<String> directionCoefficients =
      GeneratedColumn<String>(
        'direction_coefficients',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('{}'),
      );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('offline_test'),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    location,
    floorCoefficients,
    directionCoefficients,
    userId,
    isDeleted,
    createdAt,
    updatedAt,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'buildings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Building> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('floor_coefficients')) {
      context.handle(
        _floorCoefficientsMeta,
        floorCoefficients.isAcceptableOrUnknown(
          data['floor_coefficients']!,
          _floorCoefficientsMeta,
        ),
      );
    }
    if (data.containsKey('direction_coefficients')) {
      context.handle(
        _directionCoefficientsMeta,
        directionCoefficients.isAcceptableOrUnknown(
          data['direction_coefficients']!,
          _directionCoefficientsMeta,
        ),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Building map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Building(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
      floorCoefficients: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}floor_coefficients'],
      )!,
      directionCoefficients: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}direction_coefficients'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  $BuildingsTable createAlias(String alias) {
    return $BuildingsTable(attachedDatabase, alias);
  }
}

class Building extends DataClass implements Insertable<Building> {
  final String id;
  final String name;
  final String? location;
  final String floorCoefficients;
  final String directionCoefficients;
  final String userId;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;
  const Building({
    required this.id,
    required this.name,
    this.location,
    required this.floorCoefficients,
    required this.directionCoefficients,
    required this.userId,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    map['floor_coefficients'] = Variable<String>(floorCoefficients);
    map['direction_coefficients'] = Variable<String>(directionCoefficients);
    map['user_id'] = Variable<String>(userId);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  BuildingsCompanion toCompanion(bool nullToAbsent) {
    return BuildingsCompanion(
      id: Value(id),
      name: Value(name),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      floorCoefficients: Value(floorCoefficients),
      directionCoefficients: Value(directionCoefficients),
      userId: Value(userId),
      isDeleted: Value(isDeleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isSynced: Value(isSynced),
    );
  }

  factory Building.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Building(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      location: serializer.fromJson<String?>(json['location']),
      floorCoefficients: serializer.fromJson<String>(json['floorCoefficients']),
      directionCoefficients: serializer.fromJson<String>(
        json['directionCoefficients'],
      ),
      userId: serializer.fromJson<String>(json['userId']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'location': serializer.toJson<String?>(location),
      'floorCoefficients': serializer.toJson<String>(floorCoefficients),
      'directionCoefficients': serializer.toJson<String>(directionCoefficients),
      'userId': serializer.toJson<String>(userId),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  Building copyWith({
    String? id,
    String? name,
    Value<String?> location = const Value.absent(),
    String? floorCoefficients,
    String? directionCoefficients,
    String? userId,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) => Building(
    id: id ?? this.id,
    name: name ?? this.name,
    location: location.present ? location.value : this.location,
    floorCoefficients: floorCoefficients ?? this.floorCoefficients,
    directionCoefficients: directionCoefficients ?? this.directionCoefficients,
    userId: userId ?? this.userId,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isSynced: isSynced ?? this.isSynced,
  );
  Building copyWithCompanion(BuildingsCompanion data) {
    return Building(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      location: data.location.present ? data.location.value : this.location,
      floorCoefficients: data.floorCoefficients.present
          ? data.floorCoefficients.value
          : this.floorCoefficients,
      directionCoefficients: data.directionCoefficients.present
          ? data.directionCoefficients.value
          : this.directionCoefficients,
      userId: data.userId.present ? data.userId.value : this.userId,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Building(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('location: $location, ')
          ..write('floorCoefficients: $floorCoefficients, ')
          ..write('directionCoefficients: $directionCoefficients, ')
          ..write('userId: $userId, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    location,
    floorCoefficients,
    directionCoefficients,
    userId,
    isDeleted,
    createdAt,
    updatedAt,
    isSynced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Building &&
          other.id == this.id &&
          other.name == this.name &&
          other.location == this.location &&
          other.floorCoefficients == this.floorCoefficients &&
          other.directionCoefficients == this.directionCoefficients &&
          other.userId == this.userId &&
          other.isDeleted == this.isDeleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isSynced == this.isSynced);
}

class BuildingsCompanion extends UpdateCompanion<Building> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> location;
  final Value<String> floorCoefficients;
  final Value<String> directionCoefficients;
  final Value<String> userId;
  final Value<bool> isDeleted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isSynced;
  final Value<int> rowid;
  const BuildingsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.location = const Value.absent(),
    this.floorCoefficients = const Value.absent(),
    this.directionCoefficients = const Value.absent(),
    this.userId = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BuildingsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.location = const Value.absent(),
    this.floorCoefficients = const Value.absent(),
    this.directionCoefficients = const Value.absent(),
    this.userId = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Building> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? location,
    Expression<String>? floorCoefficients,
    Expression<String>? directionCoefficients,
    Expression<String>? userId,
    Expression<bool>? isDeleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (location != null) 'location': location,
      if (floorCoefficients != null) 'floor_coefficients': floorCoefficients,
      if (directionCoefficients != null)
        'direction_coefficients': directionCoefficients,
      if (userId != null) 'user_id': userId,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BuildingsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? location,
    Value<String>? floorCoefficients,
    Value<String>? directionCoefficients,
    Value<String>? userId,
    Value<bool>? isDeleted,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isSynced,
    Value<int>? rowid,
  }) {
    return BuildingsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      floorCoefficients: floorCoefficients ?? this.floorCoefficients,
      directionCoefficients:
          directionCoefficients ?? this.directionCoefficients,
      userId: userId ?? this.userId,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (floorCoefficients.present) {
      map['floor_coefficients'] = Variable<String>(floorCoefficients.value);
    }
    if (directionCoefficients.present) {
      map['direction_coefficients'] = Variable<String>(
        directionCoefficients.value,
      );
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BuildingsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('location: $location, ')
          ..write('floorCoefficients: $floorCoefficients, ')
          ..write('directionCoefficients: $directionCoefficients, ')
          ..write('userId: $userId, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ApartmentsTable extends Apartments
    with TableInfo<$ApartmentsTable, Apartment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ApartmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v7(),
  );
  static const VerificationMeta _buildingIdMeta = const VerificationMeta(
    'buildingId',
  );
  @override
  late final GeneratedColumn<String> buildingId = GeneratedColumn<String>(
    'building_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES buildings (id)',
    ),
  );
  static const VerificationMeta _unitTypeMeta = const VerificationMeta(
    'unitType',
  );
  @override
  late final GeneratedColumn<String> unitType = GeneratedColumn<String>(
    'unit_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('apartment'),
  );
  static const VerificationMeta _apartmentNumberMeta = const VerificationMeta(
    'apartmentNumber',
  );
  @override
  late final GeneratedColumn<String> apartmentNumber = GeneratedColumn<String>(
    'apartment_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _areaMeta = const VerificationMeta('area');
  @override
  late final GeneratedColumn<double> area = GeneratedColumn<double>(
    'area',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _floorNameMeta = const VerificationMeta(
    'floorName',
  );
  @override
  late final GeneratedColumn<String> floorName = GeneratedColumn<String>(
    'floor_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _directionNameMeta = const VerificationMeta(
    'directionName',
  );
  @override
  late final GeneratedColumn<String> directionName = GeneratedColumn<String>(
    'direction_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customCoefficientsMeta =
      const VerificationMeta('customCoefficients');
  @override
  late final GeneratedColumn<String> customCoefficients =
      GeneratedColumn<String>(
        'custom_coefficients',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('{}'),
      );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('available'),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('offline_test'),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    buildingId,
    unitType,
    apartmentNumber,
    area,
    floorName,
    directionName,
    customCoefficients,
    status,
    userId,
    isDeleted,
    createdAt,
    updatedAt,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'apartments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Apartment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('building_id')) {
      context.handle(
        _buildingIdMeta,
        buildingId.isAcceptableOrUnknown(data['building_id']!, _buildingIdMeta),
      );
    } else if (isInserting) {
      context.missing(_buildingIdMeta);
    }
    if (data.containsKey('unit_type')) {
      context.handle(
        _unitTypeMeta,
        unitType.isAcceptableOrUnknown(data['unit_type']!, _unitTypeMeta),
      );
    }
    if (data.containsKey('apartment_number')) {
      context.handle(
        _apartmentNumberMeta,
        apartmentNumber.isAcceptableOrUnknown(
          data['apartment_number']!,
          _apartmentNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_apartmentNumberMeta);
    }
    if (data.containsKey('area')) {
      context.handle(
        _areaMeta,
        area.isAcceptableOrUnknown(data['area']!, _areaMeta),
      );
    } else if (isInserting) {
      context.missing(_areaMeta);
    }
    if (data.containsKey('floor_name')) {
      context.handle(
        _floorNameMeta,
        floorName.isAcceptableOrUnknown(data['floor_name']!, _floorNameMeta),
      );
    } else if (isInserting) {
      context.missing(_floorNameMeta);
    }
    if (data.containsKey('direction_name')) {
      context.handle(
        _directionNameMeta,
        directionName.isAcceptableOrUnknown(
          data['direction_name']!,
          _directionNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_directionNameMeta);
    }
    if (data.containsKey('custom_coefficients')) {
      context.handle(
        _customCoefficientsMeta,
        customCoefficients.isAcceptableOrUnknown(
          data['custom_coefficients']!,
          _customCoefficientsMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Apartment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Apartment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      buildingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}building_id'],
      )!,
      unitType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_type'],
      )!,
      apartmentNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}apartment_number'],
      )!,
      area: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}area'],
      )!,
      floorName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}floor_name'],
      )!,
      directionName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}direction_name'],
      )!,
      customCoefficients: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}custom_coefficients'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  $ApartmentsTable createAlias(String alias) {
    return $ApartmentsTable(attachedDatabase, alias);
  }
}

class Apartment extends DataClass implements Insertable<Apartment> {
  final String id;
  final String buildingId;
  final String unitType;
  final String apartmentNumber;
  final double area;
  final String floorName;
  final String directionName;
  final String customCoefficients;
  final String status;
  final String userId;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isSynced;
  const Apartment({
    required this.id,
    required this.buildingId,
    required this.unitType,
    required this.apartmentNumber,
    required this.area,
    required this.floorName,
    required this.directionName,
    required this.customCoefficients,
    required this.status,
    required this.userId,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['building_id'] = Variable<String>(buildingId);
    map['unit_type'] = Variable<String>(unitType);
    map['apartment_number'] = Variable<String>(apartmentNumber);
    map['area'] = Variable<double>(area);
    map['floor_name'] = Variable<String>(floorName);
    map['direction_name'] = Variable<String>(directionName);
    map['custom_coefficients'] = Variable<String>(customCoefficients);
    map['status'] = Variable<String>(status);
    map['user_id'] = Variable<String>(userId);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  ApartmentsCompanion toCompanion(bool nullToAbsent) {
    return ApartmentsCompanion(
      id: Value(id),
      buildingId: Value(buildingId),
      unitType: Value(unitType),
      apartmentNumber: Value(apartmentNumber),
      area: Value(area),
      floorName: Value(floorName),
      directionName: Value(directionName),
      customCoefficients: Value(customCoefficients),
      status: Value(status),
      userId: Value(userId),
      isDeleted: Value(isDeleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isSynced: Value(isSynced),
    );
  }

  factory Apartment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Apartment(
      id: serializer.fromJson<String>(json['id']),
      buildingId: serializer.fromJson<String>(json['buildingId']),
      unitType: serializer.fromJson<String>(json['unitType']),
      apartmentNumber: serializer.fromJson<String>(json['apartmentNumber']),
      area: serializer.fromJson<double>(json['area']),
      floorName: serializer.fromJson<String>(json['floorName']),
      directionName: serializer.fromJson<String>(json['directionName']),
      customCoefficients: serializer.fromJson<String>(
        json['customCoefficients'],
      ),
      status: serializer.fromJson<String>(json['status']),
      userId: serializer.fromJson<String>(json['userId']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'buildingId': serializer.toJson<String>(buildingId),
      'unitType': serializer.toJson<String>(unitType),
      'apartmentNumber': serializer.toJson<String>(apartmentNumber),
      'area': serializer.toJson<double>(area),
      'floorName': serializer.toJson<String>(floorName),
      'directionName': serializer.toJson<String>(directionName),
      'customCoefficients': serializer.toJson<String>(customCoefficients),
      'status': serializer.toJson<String>(status),
      'userId': serializer.toJson<String>(userId),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  Apartment copyWith({
    String? id,
    String? buildingId,
    String? unitType,
    String? apartmentNumber,
    double? area,
    String? floorName,
    String? directionName,
    String? customCoefficients,
    String? status,
    String? userId,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
  }) => Apartment(
    id: id ?? this.id,
    buildingId: buildingId ?? this.buildingId,
    unitType: unitType ?? this.unitType,
    apartmentNumber: apartmentNumber ?? this.apartmentNumber,
    area: area ?? this.area,
    floorName: floorName ?? this.floorName,
    directionName: directionName ?? this.directionName,
    customCoefficients: customCoefficients ?? this.customCoefficients,
    status: status ?? this.status,
    userId: userId ?? this.userId,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isSynced: isSynced ?? this.isSynced,
  );
  Apartment copyWithCompanion(ApartmentsCompanion data) {
    return Apartment(
      id: data.id.present ? data.id.value : this.id,
      buildingId: data.buildingId.present
          ? data.buildingId.value
          : this.buildingId,
      unitType: data.unitType.present ? data.unitType.value : this.unitType,
      apartmentNumber: data.apartmentNumber.present
          ? data.apartmentNumber.value
          : this.apartmentNumber,
      area: data.area.present ? data.area.value : this.area,
      floorName: data.floorName.present ? data.floorName.value : this.floorName,
      directionName: data.directionName.present
          ? data.directionName.value
          : this.directionName,
      customCoefficients: data.customCoefficients.present
          ? data.customCoefficients.value
          : this.customCoefficients,
      status: data.status.present ? data.status.value : this.status,
      userId: data.userId.present ? data.userId.value : this.userId,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Apartment(')
          ..write('id: $id, ')
          ..write('buildingId: $buildingId, ')
          ..write('unitType: $unitType, ')
          ..write('apartmentNumber: $apartmentNumber, ')
          ..write('area: $area, ')
          ..write('floorName: $floorName, ')
          ..write('directionName: $directionName, ')
          ..write('customCoefficients: $customCoefficients, ')
          ..write('status: $status, ')
          ..write('userId: $userId, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    buildingId,
    unitType,
    apartmentNumber,
    area,
    floorName,
    directionName,
    customCoefficients,
    status,
    userId,
    isDeleted,
    createdAt,
    updatedAt,
    isSynced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Apartment &&
          other.id == this.id &&
          other.buildingId == this.buildingId &&
          other.unitType == this.unitType &&
          other.apartmentNumber == this.apartmentNumber &&
          other.area == this.area &&
          other.floorName == this.floorName &&
          other.directionName == this.directionName &&
          other.customCoefficients == this.customCoefficients &&
          other.status == this.status &&
          other.userId == this.userId &&
          other.isDeleted == this.isDeleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isSynced == this.isSynced);
}

class ApartmentsCompanion extends UpdateCompanion<Apartment> {
  final Value<String> id;
  final Value<String> buildingId;
  final Value<String> unitType;
  final Value<String> apartmentNumber;
  final Value<double> area;
  final Value<String> floorName;
  final Value<String> directionName;
  final Value<String> customCoefficients;
  final Value<String> status;
  final Value<String> userId;
  final Value<bool> isDeleted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isSynced;
  final Value<int> rowid;
  const ApartmentsCompanion({
    this.id = const Value.absent(),
    this.buildingId = const Value.absent(),
    this.unitType = const Value.absent(),
    this.apartmentNumber = const Value.absent(),
    this.area = const Value.absent(),
    this.floorName = const Value.absent(),
    this.directionName = const Value.absent(),
    this.customCoefficients = const Value.absent(),
    this.status = const Value.absent(),
    this.userId = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ApartmentsCompanion.insert({
    this.id = const Value.absent(),
    required String buildingId,
    this.unitType = const Value.absent(),
    required String apartmentNumber,
    required double area,
    required String floorName,
    required String directionName,
    this.customCoefficients = const Value.absent(),
    this.status = const Value.absent(),
    this.userId = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : buildingId = Value(buildingId),
       apartmentNumber = Value(apartmentNumber),
       area = Value(area),
       floorName = Value(floorName),
       directionName = Value(directionName);
  static Insertable<Apartment> custom({
    Expression<String>? id,
    Expression<String>? buildingId,
    Expression<String>? unitType,
    Expression<String>? apartmentNumber,
    Expression<double>? area,
    Expression<String>? floorName,
    Expression<String>? directionName,
    Expression<String>? customCoefficients,
    Expression<String>? status,
    Expression<String>? userId,
    Expression<bool>? isDeleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (buildingId != null) 'building_id': buildingId,
      if (unitType != null) 'unit_type': unitType,
      if (apartmentNumber != null) 'apartment_number': apartmentNumber,
      if (area != null) 'area': area,
      if (floorName != null) 'floor_name': floorName,
      if (directionName != null) 'direction_name': directionName,
      if (customCoefficients != null) 'custom_coefficients': customCoefficients,
      if (status != null) 'status': status,
      if (userId != null) 'user_id': userId,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isSynced != null) 'is_synced': isSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ApartmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? buildingId,
    Value<String>? unitType,
    Value<String>? apartmentNumber,
    Value<double>? area,
    Value<String>? floorName,
    Value<String>? directionName,
    Value<String>? customCoefficients,
    Value<String>? status,
    Value<String>? userId,
    Value<bool>? isDeleted,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isSynced,
    Value<int>? rowid,
  }) {
    return ApartmentsCompanion(
      id: id ?? this.id,
      buildingId: buildingId ?? this.buildingId,
      unitType: unitType ?? this.unitType,
      apartmentNumber: apartmentNumber ?? this.apartmentNumber,
      area: area ?? this.area,
      floorName: floorName ?? this.floorName,
      directionName: directionName ?? this.directionName,
      customCoefficients: customCoefficients ?? this.customCoefficients,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (buildingId.present) {
      map['building_id'] = Variable<String>(buildingId.value);
    }
    if (unitType.present) {
      map['unit_type'] = Variable<String>(unitType.value);
    }
    if (apartmentNumber.present) {
      map['apartment_number'] = Variable<String>(apartmentNumber.value);
    }
    if (area.present) {
      map['area'] = Variable<double>(area.value);
    }
    if (floorName.present) {
      map['floor_name'] = Variable<String>(floorName.value);
    }
    if (directionName.present) {
      map['direction_name'] = Variable<String>(directionName.value);
    }
    if (customCoefficients.present) {
      map['custom_coefficients'] = Variable<String>(customCoefficients.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ApartmentsCompanion(')
          ..write('id: $id, ')
          ..write('buildingId: $buildingId, ')
          ..write('unitType: $unitType, ')
          ..write('apartmentNumber: $apartmentNumber, ')
          ..write('area: $area, ')
          ..write('floorName: $floorName, ')
          ..write('directionName: $directionName, ')
          ..write('customCoefficients: $customCoefficients, ')
          ..write('status: $status, ')
          ..write('userId: $userId, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isSynced: $isSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ContractsTable extends Contracts
    with TableInfo<$ContractsTable, Contract> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContractsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v7(),
  );
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES clients (id)',
    ),
  );
  static const VerificationMeta _apartmentIdMeta = const VerificationMeta(
    'apartmentId',
  );
  @override
  late final GeneratedColumn<String> apartmentId = GeneratedColumn<String>(
    'apartment_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES apartments (id)',
    ),
  );
  static const VerificationMeta _apartmentDetailsMeta = const VerificationMeta(
    'apartmentDetails',
  );
  @override
  late final GeneratedColumn<String> apartmentDetails = GeneratedColumn<String>(
    'apartment_details',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('أسهم/غير مخصص'),
  );
  static const VerificationMeta _contractTypeMeta = const VerificationMeta(
    'contractType',
  );
  @override
  late final GeneratedColumn<String> contractType = GeneratedColumn<String>(
    'contract_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('لاحق التخصص'),
  );
  static const VerificationMeta _totalAreaMeta = const VerificationMeta(
    'totalArea',
  );
  @override
  late final GeneratedColumn<double> totalArea = GeneratedColumn<double>(
    'total_area',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baseMeterPriceAtSigningMeta =
      const VerificationMeta('baseMeterPriceAtSigning');
  @override
  late final GeneratedColumn<double> baseMeterPriceAtSigning =
      GeneratedColumn<double>(
        'base_meter_price_at_signing',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _isPenaltyActiveMeta = const VerificationMeta(
    'isPenaltyActive',
  );
  @override
  late final GeneratedColumn<bool> isPenaltyActive = GeneratedColumn<bool>(
    'is_penalty_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_penalty_active" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _penaltyPercentageMeta = const VerificationMeta(
    'penaltyPercentage',
  );
  @override
  late final GeneratedColumn<double> penaltyPercentage =
      GeneratedColumn<double>(
        'penalty_percentage',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0.0),
      );
  static const VerificationMeta _penaltyIntervalMonthsMeta =
      const VerificationMeta('penaltyIntervalMonths');
  @override
  late final GeneratedColumn<int> penaltyIntervalMonths = GeneratedColumn<int>(
    'penalty_interval_months',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _downPaymentMeta = const VerificationMeta(
    'downPayment',
  );
  @override
  late final GeneratedColumn<double> downPayment = GeneratedColumn<double>(
    'down_payment',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _isHandedOverMeta = const VerificationMeta(
    'isHandedOver',
  );
  @override
  late final GeneratedColumn<bool> isHandedOver = GeneratedColumn<bool>(
    'is_handed_over',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_handed_over" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _agreedHandoverDateMeta =
      const VerificationMeta('agreedHandoverDate');
  @override
  late final GeneratedColumn<DateTime> agreedHandoverDate =
      GeneratedColumn<DateTime>(
        'agreed_handover_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _actualHandoverDateMeta =
      const VerificationMeta('actualHandoverDate');
  @override
  late final GeneratedColumn<DateTime> actualHandoverDate =
      GeneratedColumn<DateTime>(
        'actual_handover_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _gracePeriodMonthsMeta = const VerificationMeta(
    'gracePeriodMonths',
  );
  @override
  late final GeneratedColumn<int> gracePeriodMonths = GeneratedColumn<int>(
    'grace_period_months',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _handoverNotesMeta = const VerificationMeta(
    'handoverNotes',
  );
  @override
  late final GeneratedColumn<String> handoverNotes = GeneratedColumn<String>(
    'handover_notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _installmentsCountMeta = const VerificationMeta(
    'installmentsCount',
  );
  @override
  late final GeneratedColumn<int> installmentsCount = GeneratedColumn<int>(
    'installments_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(48),
  );
  static const VerificationMeta _coefficientsMeta = const VerificationMeta(
    'coefficients',
  );
  @override
  late final GeneratedColumn<String> coefficients = GeneratedColumn<String>(
    'coefficients',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _guarantorNameMeta = const VerificationMeta(
    'guarantorName',
  );
  @override
  late final GeneratedColumn<String> guarantorName = GeneratedColumn<String>(
    'guarantor_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contractFileUrlMeta = const VerificationMeta(
    'contractFileUrl',
  );
  @override
  late final GeneratedColumn<String> contractFileUrl = GeneratedColumn<String>(
    'contract_file_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _agreedMonthlyAmountMeta =
      const VerificationMeta('agreedMonthlyAmount');
  @override
  late final GeneratedColumn<double> agreedMonthlyAmount =
      GeneratedColumn<double>(
        'agreed_monthly_amount',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(0.0),
      );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contractDateMeta = const VerificationMeta(
    'contractDate',
  );
  @override
  late final GeneratedColumn<DateTime> contractDate = GeneratedColumn<DateTime>(
    'contract_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _lastActionDateMeta = const VerificationMeta(
    'lastActionDate',
  );
  @override
  late final GeneratedColumn<DateTime> lastActionDate =
      GeneratedColumn<DateTime>(
        'last_action_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastActionNoteMeta = const VerificationMeta(
    'lastActionNote',
  );
  @override
  late final GeneratedColumn<String> lastActionNote = GeneratedColumn<String>(
    'last_action_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    clientId,
    apartmentId,
    apartmentDetails,
    contractType,
    totalArea,
    baseMeterPriceAtSigning,
    isPenaltyActive,
    penaltyPercentage,
    penaltyIntervalMonths,
    downPayment,
    isHandedOver,
    agreedHandoverDate,
    actualHandoverDate,
    gracePeriodMonths,
    handoverNotes,
    installmentsCount,
    coefficients,
    guarantorName,
    contractFileUrl,
    agreedMonthlyAmount,
    userId,
    contractDate,
    isCompleted,
    createdAt,
    updatedAt,
    lastActionDate,
    lastActionNote,
    isDeleted,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contracts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Contract> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('apartment_id')) {
      context.handle(
        _apartmentIdMeta,
        apartmentId.isAcceptableOrUnknown(
          data['apartment_id']!,
          _apartmentIdMeta,
        ),
      );
    }
    if (data.containsKey('apartment_details')) {
      context.handle(
        _apartmentDetailsMeta,
        apartmentDetails.isAcceptableOrUnknown(
          data['apartment_details']!,
          _apartmentDetailsMeta,
        ),
      );
    }
    if (data.containsKey('contract_type')) {
      context.handle(
        _contractTypeMeta,
        contractType.isAcceptableOrUnknown(
          data['contract_type']!,
          _contractTypeMeta,
        ),
      );
    }
    if (data.containsKey('total_area')) {
      context.handle(
        _totalAreaMeta,
        totalArea.isAcceptableOrUnknown(data['total_area']!, _totalAreaMeta),
      );
    } else if (isInserting) {
      context.missing(_totalAreaMeta);
    }
    if (data.containsKey('base_meter_price_at_signing')) {
      context.handle(
        _baseMeterPriceAtSigningMeta,
        baseMeterPriceAtSigning.isAcceptableOrUnknown(
          data['base_meter_price_at_signing']!,
          _baseMeterPriceAtSigningMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_baseMeterPriceAtSigningMeta);
    }
    if (data.containsKey('is_penalty_active')) {
      context.handle(
        _isPenaltyActiveMeta,
        isPenaltyActive.isAcceptableOrUnknown(
          data['is_penalty_active']!,
          _isPenaltyActiveMeta,
        ),
      );
    }
    if (data.containsKey('penalty_percentage')) {
      context.handle(
        _penaltyPercentageMeta,
        penaltyPercentage.isAcceptableOrUnknown(
          data['penalty_percentage']!,
          _penaltyPercentageMeta,
        ),
      );
    }
    if (data.containsKey('penalty_interval_months')) {
      context.handle(
        _penaltyIntervalMonthsMeta,
        penaltyIntervalMonths.isAcceptableOrUnknown(
          data['penalty_interval_months']!,
          _penaltyIntervalMonthsMeta,
        ),
      );
    }
    if (data.containsKey('down_payment')) {
      context.handle(
        _downPaymentMeta,
        downPayment.isAcceptableOrUnknown(
          data['down_payment']!,
          _downPaymentMeta,
        ),
      );
    }
    if (data.containsKey('is_handed_over')) {
      context.handle(
        _isHandedOverMeta,
        isHandedOver.isAcceptableOrUnknown(
          data['is_handed_over']!,
          _isHandedOverMeta,
        ),
      );
    }
    if (data.containsKey('agreed_handover_date')) {
      context.handle(
        _agreedHandoverDateMeta,
        agreedHandoverDate.isAcceptableOrUnknown(
          data['agreed_handover_date']!,
          _agreedHandoverDateMeta,
        ),
      );
    }
    if (data.containsKey('actual_handover_date')) {
      context.handle(
        _actualHandoverDateMeta,
        actualHandoverDate.isAcceptableOrUnknown(
          data['actual_handover_date']!,
          _actualHandoverDateMeta,
        ),
      );
    }
    if (data.containsKey('grace_period_months')) {
      context.handle(
        _gracePeriodMonthsMeta,
        gracePeriodMonths.isAcceptableOrUnknown(
          data['grace_period_months']!,
          _gracePeriodMonthsMeta,
        ),
      );
    }
    if (data.containsKey('handover_notes')) {
      context.handle(
        _handoverNotesMeta,
        handoverNotes.isAcceptableOrUnknown(
          data['handover_notes']!,
          _handoverNotesMeta,
        ),
      );
    }
    if (data.containsKey('installments_count')) {
      context.handle(
        _installmentsCountMeta,
        installmentsCount.isAcceptableOrUnknown(
          data['installments_count']!,
          _installmentsCountMeta,
        ),
      );
    }
    if (data.containsKey('coefficients')) {
      context.handle(
        _coefficientsMeta,
        coefficients.isAcceptableOrUnknown(
          data['coefficients']!,
          _coefficientsMeta,
        ),
      );
    }
    if (data.containsKey('guarantor_name')) {
      context.handle(
        _guarantorNameMeta,
        guarantorName.isAcceptableOrUnknown(
          data['guarantor_name']!,
          _guarantorNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_guarantorNameMeta);
    }
    if (data.containsKey('contract_file_url')) {
      context.handle(
        _contractFileUrlMeta,
        contractFileUrl.isAcceptableOrUnknown(
          data['contract_file_url']!,
          _contractFileUrlMeta,
        ),
      );
    }
    if (data.containsKey('agreed_monthly_amount')) {
      context.handle(
        _agreedMonthlyAmountMeta,
        agreedMonthlyAmount.isAcceptableOrUnknown(
          data['agreed_monthly_amount']!,
          _agreedMonthlyAmountMeta,
        ),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('contract_date')) {
      context.handle(
        _contractDateMeta,
        contractDate.isAcceptableOrUnknown(
          data['contract_date']!,
          _contractDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contractDateMeta);
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('last_action_date')) {
      context.handle(
        _lastActionDateMeta,
        lastActionDate.isAcceptableOrUnknown(
          data['last_action_date']!,
          _lastActionDateMeta,
        ),
      );
    }
    if (data.containsKey('last_action_note')) {
      context.handle(
        _lastActionNoteMeta,
        lastActionNote.isAcceptableOrUnknown(
          data['last_action_note']!,
          _lastActionNoteMeta,
        ),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Contract map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Contract(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      )!,
      apartmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}apartment_id'],
      ),
      apartmentDetails: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}apartment_details'],
      )!,
      contractType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contract_type'],
      )!,
      totalArea: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_area'],
      )!,
      baseMeterPriceAtSigning: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}base_meter_price_at_signing'],
      )!,
      isPenaltyActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_penalty_active'],
      )!,
      penaltyPercentage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}penalty_percentage'],
      )!,
      penaltyIntervalMonths: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}penalty_interval_months'],
      )!,
      downPayment: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}down_payment'],
      )!,
      isHandedOver: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_handed_over'],
      )!,
      agreedHandoverDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}agreed_handover_date'],
      ),
      actualHandoverDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}actual_handover_date'],
      ),
      gracePeriodMonths: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}grace_period_months'],
      )!,
      handoverNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}handover_notes'],
      ),
      installmentsCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}installments_count'],
      )!,
      coefficients: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}coefficients'],
      )!,
      guarantorName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}guarantor_name'],
      )!,
      contractFileUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contract_file_url'],
      ),
      agreedMonthlyAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}agreed_monthly_amount'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      contractDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}contract_date'],
      )!,
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      lastActionDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_action_date'],
      ),
      lastActionNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_action_note'],
      ),
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  $ContractsTable createAlias(String alias) {
    return $ContractsTable(attachedDatabase, alias);
  }
}

class Contract extends DataClass implements Insertable<Contract> {
  final String id;
  final String clientId;
  final String? apartmentId;
  final String apartmentDetails;
  final String contractType;
  final double totalArea;
  final double baseMeterPriceAtSigning;
  final bool isPenaltyActive;
  final double penaltyPercentage;
  final int penaltyIntervalMonths;
  final double downPayment;
  final bool isHandedOver;
  final DateTime? agreedHandoverDate;
  final DateTime? actualHandoverDate;
  final int gracePeriodMonths;
  final String? handoverNotes;
  final int installmentsCount;
  final String coefficients;
  final String guarantorName;
  final String? contractFileUrl;
  final double agreedMonthlyAmount;
  final String userId;
  final DateTime contractDate;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastActionDate;
  final String? lastActionNote;
  final bool isDeleted;
  final bool isSynced;
  const Contract({
    required this.id,
    required this.clientId,
    this.apartmentId,
    required this.apartmentDetails,
    required this.contractType,
    required this.totalArea,
    required this.baseMeterPriceAtSigning,
    required this.isPenaltyActive,
    required this.penaltyPercentage,
    required this.penaltyIntervalMonths,
    required this.downPayment,
    required this.isHandedOver,
    this.agreedHandoverDate,
    this.actualHandoverDate,
    required this.gracePeriodMonths,
    this.handoverNotes,
    required this.installmentsCount,
    required this.coefficients,
    required this.guarantorName,
    this.contractFileUrl,
    required this.agreedMonthlyAmount,
    required this.userId,
    required this.contractDate,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
    this.lastActionDate,
    this.lastActionNote,
    required this.isDeleted,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['client_id'] = Variable<String>(clientId);
    if (!nullToAbsent || apartmentId != null) {
      map['apartment_id'] = Variable<String>(apartmentId);
    }
    map['apartment_details'] = Variable<String>(apartmentDetails);
    map['contract_type'] = Variable<String>(contractType);
    map['total_area'] = Variable<double>(totalArea);
    map['base_meter_price_at_signing'] = Variable<double>(
      baseMeterPriceAtSigning,
    );
    map['is_penalty_active'] = Variable<bool>(isPenaltyActive);
    map['penalty_percentage'] = Variable<double>(penaltyPercentage);
    map['penalty_interval_months'] = Variable<int>(penaltyIntervalMonths);
    map['down_payment'] = Variable<double>(downPayment);
    map['is_handed_over'] = Variable<bool>(isHandedOver);
    if (!nullToAbsent || agreedHandoverDate != null) {
      map['agreed_handover_date'] = Variable<DateTime>(agreedHandoverDate);
    }
    if (!nullToAbsent || actualHandoverDate != null) {
      map['actual_handover_date'] = Variable<DateTime>(actualHandoverDate);
    }
    map['grace_period_months'] = Variable<int>(gracePeriodMonths);
    if (!nullToAbsent || handoverNotes != null) {
      map['handover_notes'] = Variable<String>(handoverNotes);
    }
    map['installments_count'] = Variable<int>(installmentsCount);
    map['coefficients'] = Variable<String>(coefficients);
    map['guarantor_name'] = Variable<String>(guarantorName);
    if (!nullToAbsent || contractFileUrl != null) {
      map['contract_file_url'] = Variable<String>(contractFileUrl);
    }
    map['agreed_monthly_amount'] = Variable<double>(agreedMonthlyAmount);
    map['user_id'] = Variable<String>(userId);
    map['contract_date'] = Variable<DateTime>(contractDate);
    map['is_completed'] = Variable<bool>(isCompleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || lastActionDate != null) {
      map['last_action_date'] = Variable<DateTime>(lastActionDate);
    }
    if (!nullToAbsent || lastActionNote != null) {
      map['last_action_note'] = Variable<String>(lastActionNote);
    }
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  ContractsCompanion toCompanion(bool nullToAbsent) {
    return ContractsCompanion(
      id: Value(id),
      clientId: Value(clientId),
      apartmentId: apartmentId == null && nullToAbsent
          ? const Value.absent()
          : Value(apartmentId),
      apartmentDetails: Value(apartmentDetails),
      contractType: Value(contractType),
      totalArea: Value(totalArea),
      baseMeterPriceAtSigning: Value(baseMeterPriceAtSigning),
      isPenaltyActive: Value(isPenaltyActive),
      penaltyPercentage: Value(penaltyPercentage),
      penaltyIntervalMonths: Value(penaltyIntervalMonths),
      downPayment: Value(downPayment),
      isHandedOver: Value(isHandedOver),
      agreedHandoverDate: agreedHandoverDate == null && nullToAbsent
          ? const Value.absent()
          : Value(agreedHandoverDate),
      actualHandoverDate: actualHandoverDate == null && nullToAbsent
          ? const Value.absent()
          : Value(actualHandoverDate),
      gracePeriodMonths: Value(gracePeriodMonths),
      handoverNotes: handoverNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(handoverNotes),
      installmentsCount: Value(installmentsCount),
      coefficients: Value(coefficients),
      guarantorName: Value(guarantorName),
      contractFileUrl: contractFileUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(contractFileUrl),
      agreedMonthlyAmount: Value(agreedMonthlyAmount),
      userId: Value(userId),
      contractDate: Value(contractDate),
      isCompleted: Value(isCompleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      lastActionDate: lastActionDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastActionDate),
      lastActionNote: lastActionNote == null && nullToAbsent
          ? const Value.absent()
          : Value(lastActionNote),
      isDeleted: Value(isDeleted),
      isSynced: Value(isSynced),
    );
  }

  factory Contract.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Contract(
      id: serializer.fromJson<String>(json['id']),
      clientId: serializer.fromJson<String>(json['clientId']),
      apartmentId: serializer.fromJson<String?>(json['apartmentId']),
      apartmentDetails: serializer.fromJson<String>(json['apartmentDetails']),
      contractType: serializer.fromJson<String>(json['contractType']),
      totalArea: serializer.fromJson<double>(json['totalArea']),
      baseMeterPriceAtSigning: serializer.fromJson<double>(
        json['baseMeterPriceAtSigning'],
      ),
      isPenaltyActive: serializer.fromJson<bool>(json['isPenaltyActive']),
      penaltyPercentage: serializer.fromJson<double>(json['penaltyPercentage']),
      penaltyIntervalMonths: serializer.fromJson<int>(
        json['penaltyIntervalMonths'],
      ),
      downPayment: serializer.fromJson<double>(json['downPayment']),
      isHandedOver: serializer.fromJson<bool>(json['isHandedOver']),
      agreedHandoverDate: serializer.fromJson<DateTime?>(
        json['agreedHandoverDate'],
      ),
      actualHandoverDate: serializer.fromJson<DateTime?>(
        json['actualHandoverDate'],
      ),
      gracePeriodMonths: serializer.fromJson<int>(json['gracePeriodMonths']),
      handoverNotes: serializer.fromJson<String?>(json['handoverNotes']),
      installmentsCount: serializer.fromJson<int>(json['installmentsCount']),
      coefficients: serializer.fromJson<String>(json['coefficients']),
      guarantorName: serializer.fromJson<String>(json['guarantorName']),
      contractFileUrl: serializer.fromJson<String?>(json['contractFileUrl']),
      agreedMonthlyAmount: serializer.fromJson<double>(
        json['agreedMonthlyAmount'],
      ),
      userId: serializer.fromJson<String>(json['userId']),
      contractDate: serializer.fromJson<DateTime>(json['contractDate']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      lastActionDate: serializer.fromJson<DateTime?>(json['lastActionDate']),
      lastActionNote: serializer.fromJson<String?>(json['lastActionNote']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'clientId': serializer.toJson<String>(clientId),
      'apartmentId': serializer.toJson<String?>(apartmentId),
      'apartmentDetails': serializer.toJson<String>(apartmentDetails),
      'contractType': serializer.toJson<String>(contractType),
      'totalArea': serializer.toJson<double>(totalArea),
      'baseMeterPriceAtSigning': serializer.toJson<double>(
        baseMeterPriceAtSigning,
      ),
      'isPenaltyActive': serializer.toJson<bool>(isPenaltyActive),
      'penaltyPercentage': serializer.toJson<double>(penaltyPercentage),
      'penaltyIntervalMonths': serializer.toJson<int>(penaltyIntervalMonths),
      'downPayment': serializer.toJson<double>(downPayment),
      'isHandedOver': serializer.toJson<bool>(isHandedOver),
      'agreedHandoverDate': serializer.toJson<DateTime?>(agreedHandoverDate),
      'actualHandoverDate': serializer.toJson<DateTime?>(actualHandoverDate),
      'gracePeriodMonths': serializer.toJson<int>(gracePeriodMonths),
      'handoverNotes': serializer.toJson<String?>(handoverNotes),
      'installmentsCount': serializer.toJson<int>(installmentsCount),
      'coefficients': serializer.toJson<String>(coefficients),
      'guarantorName': serializer.toJson<String>(guarantorName),
      'contractFileUrl': serializer.toJson<String?>(contractFileUrl),
      'agreedMonthlyAmount': serializer.toJson<double>(agreedMonthlyAmount),
      'userId': serializer.toJson<String>(userId),
      'contractDate': serializer.toJson<DateTime>(contractDate),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'lastActionDate': serializer.toJson<DateTime?>(lastActionDate),
      'lastActionNote': serializer.toJson<String?>(lastActionNote),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  Contract copyWith({
    String? id,
    String? clientId,
    Value<String?> apartmentId = const Value.absent(),
    String? apartmentDetails,
    String? contractType,
    double? totalArea,
    double? baseMeterPriceAtSigning,
    bool? isPenaltyActive,
    double? penaltyPercentage,
    int? penaltyIntervalMonths,
    double? downPayment,
    bool? isHandedOver,
    Value<DateTime?> agreedHandoverDate = const Value.absent(),
    Value<DateTime?> actualHandoverDate = const Value.absent(),
    int? gracePeriodMonths,
    Value<String?> handoverNotes = const Value.absent(),
    int? installmentsCount,
    String? coefficients,
    String? guarantorName,
    Value<String?> contractFileUrl = const Value.absent(),
    double? agreedMonthlyAmount,
    String? userId,
    DateTime? contractDate,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> lastActionDate = const Value.absent(),
    Value<String?> lastActionNote = const Value.absent(),
    bool? isDeleted,
    bool? isSynced,
  }) => Contract(
    id: id ?? this.id,
    clientId: clientId ?? this.clientId,
    apartmentId: apartmentId.present ? apartmentId.value : this.apartmentId,
    apartmentDetails: apartmentDetails ?? this.apartmentDetails,
    contractType: contractType ?? this.contractType,
    totalArea: totalArea ?? this.totalArea,
    baseMeterPriceAtSigning:
        baseMeterPriceAtSigning ?? this.baseMeterPriceAtSigning,
    isPenaltyActive: isPenaltyActive ?? this.isPenaltyActive,
    penaltyPercentage: penaltyPercentage ?? this.penaltyPercentage,
    penaltyIntervalMonths: penaltyIntervalMonths ?? this.penaltyIntervalMonths,
    downPayment: downPayment ?? this.downPayment,
    isHandedOver: isHandedOver ?? this.isHandedOver,
    agreedHandoverDate: agreedHandoverDate.present
        ? agreedHandoverDate.value
        : this.agreedHandoverDate,
    actualHandoverDate: actualHandoverDate.present
        ? actualHandoverDate.value
        : this.actualHandoverDate,
    gracePeriodMonths: gracePeriodMonths ?? this.gracePeriodMonths,
    handoverNotes: handoverNotes.present
        ? handoverNotes.value
        : this.handoverNotes,
    installmentsCount: installmentsCount ?? this.installmentsCount,
    coefficients: coefficients ?? this.coefficients,
    guarantorName: guarantorName ?? this.guarantorName,
    contractFileUrl: contractFileUrl.present
        ? contractFileUrl.value
        : this.contractFileUrl,
    agreedMonthlyAmount: agreedMonthlyAmount ?? this.agreedMonthlyAmount,
    userId: userId ?? this.userId,
    contractDate: contractDate ?? this.contractDate,
    isCompleted: isCompleted ?? this.isCompleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    lastActionDate: lastActionDate.present
        ? lastActionDate.value
        : this.lastActionDate,
    lastActionNote: lastActionNote.present
        ? lastActionNote.value
        : this.lastActionNote,
    isDeleted: isDeleted ?? this.isDeleted,
    isSynced: isSynced ?? this.isSynced,
  );
  Contract copyWithCompanion(ContractsCompanion data) {
    return Contract(
      id: data.id.present ? data.id.value : this.id,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      apartmentId: data.apartmentId.present
          ? data.apartmentId.value
          : this.apartmentId,
      apartmentDetails: data.apartmentDetails.present
          ? data.apartmentDetails.value
          : this.apartmentDetails,
      contractType: data.contractType.present
          ? data.contractType.value
          : this.contractType,
      totalArea: data.totalArea.present ? data.totalArea.value : this.totalArea,
      baseMeterPriceAtSigning: data.baseMeterPriceAtSigning.present
          ? data.baseMeterPriceAtSigning.value
          : this.baseMeterPriceAtSigning,
      isPenaltyActive: data.isPenaltyActive.present
          ? data.isPenaltyActive.value
          : this.isPenaltyActive,
      penaltyPercentage: data.penaltyPercentage.present
          ? data.penaltyPercentage.value
          : this.penaltyPercentage,
      penaltyIntervalMonths: data.penaltyIntervalMonths.present
          ? data.penaltyIntervalMonths.value
          : this.penaltyIntervalMonths,
      downPayment: data.downPayment.present
          ? data.downPayment.value
          : this.downPayment,
      isHandedOver: data.isHandedOver.present
          ? data.isHandedOver.value
          : this.isHandedOver,
      agreedHandoverDate: data.agreedHandoverDate.present
          ? data.agreedHandoverDate.value
          : this.agreedHandoverDate,
      actualHandoverDate: data.actualHandoverDate.present
          ? data.actualHandoverDate.value
          : this.actualHandoverDate,
      gracePeriodMonths: data.gracePeriodMonths.present
          ? data.gracePeriodMonths.value
          : this.gracePeriodMonths,
      handoverNotes: data.handoverNotes.present
          ? data.handoverNotes.value
          : this.handoverNotes,
      installmentsCount: data.installmentsCount.present
          ? data.installmentsCount.value
          : this.installmentsCount,
      coefficients: data.coefficients.present
          ? data.coefficients.value
          : this.coefficients,
      guarantorName: data.guarantorName.present
          ? data.guarantorName.value
          : this.guarantorName,
      contractFileUrl: data.contractFileUrl.present
          ? data.contractFileUrl.value
          : this.contractFileUrl,
      agreedMonthlyAmount: data.agreedMonthlyAmount.present
          ? data.agreedMonthlyAmount.value
          : this.agreedMonthlyAmount,
      userId: data.userId.present ? data.userId.value : this.userId,
      contractDate: data.contractDate.present
          ? data.contractDate.value
          : this.contractDate,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastActionDate: data.lastActionDate.present
          ? data.lastActionDate.value
          : this.lastActionDate,
      lastActionNote: data.lastActionNote.present
          ? data.lastActionNote.value
          : this.lastActionNote,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Contract(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('apartmentId: $apartmentId, ')
          ..write('apartmentDetails: $apartmentDetails, ')
          ..write('contractType: $contractType, ')
          ..write('totalArea: $totalArea, ')
          ..write('baseMeterPriceAtSigning: $baseMeterPriceAtSigning, ')
          ..write('isPenaltyActive: $isPenaltyActive, ')
          ..write('penaltyPercentage: $penaltyPercentage, ')
          ..write('penaltyIntervalMonths: $penaltyIntervalMonths, ')
          ..write('downPayment: $downPayment, ')
          ..write('isHandedOver: $isHandedOver, ')
          ..write('agreedHandoverDate: $agreedHandoverDate, ')
          ..write('actualHandoverDate: $actualHandoverDate, ')
          ..write('gracePeriodMonths: $gracePeriodMonths, ')
          ..write('handoverNotes: $handoverNotes, ')
          ..write('installmentsCount: $installmentsCount, ')
          ..write('coefficients: $coefficients, ')
          ..write('guarantorName: $guarantorName, ')
          ..write('contractFileUrl: $contractFileUrl, ')
          ..write('agreedMonthlyAmount: $agreedMonthlyAmount, ')
          ..write('userId: $userId, ')
          ..write('contractDate: $contractDate, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastActionDate: $lastActionDate, ')
          ..write('lastActionNote: $lastActionNote, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    clientId,
    apartmentId,
    apartmentDetails,
    contractType,
    totalArea,
    baseMeterPriceAtSigning,
    isPenaltyActive,
    penaltyPercentage,
    penaltyIntervalMonths,
    downPayment,
    isHandedOver,
    agreedHandoverDate,
    actualHandoverDate,
    gracePeriodMonths,
    handoverNotes,
    installmentsCount,
    coefficients,
    guarantorName,
    contractFileUrl,
    agreedMonthlyAmount,
    userId,
    contractDate,
    isCompleted,
    createdAt,
    updatedAt,
    lastActionDate,
    lastActionNote,
    isDeleted,
    isSynced,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Contract &&
          other.id == this.id &&
          other.clientId == this.clientId &&
          other.apartmentId == this.apartmentId &&
          other.apartmentDetails == this.apartmentDetails &&
          other.contractType == this.contractType &&
          other.totalArea == this.totalArea &&
          other.baseMeterPriceAtSigning == this.baseMeterPriceAtSigning &&
          other.isPenaltyActive == this.isPenaltyActive &&
          other.penaltyPercentage == this.penaltyPercentage &&
          other.penaltyIntervalMonths == this.penaltyIntervalMonths &&
          other.downPayment == this.downPayment &&
          other.isHandedOver == this.isHandedOver &&
          other.agreedHandoverDate == this.agreedHandoverDate &&
          other.actualHandoverDate == this.actualHandoverDate &&
          other.gracePeriodMonths == this.gracePeriodMonths &&
          other.handoverNotes == this.handoverNotes &&
          other.installmentsCount == this.installmentsCount &&
          other.coefficients == this.coefficients &&
          other.guarantorName == this.guarantorName &&
          other.contractFileUrl == this.contractFileUrl &&
          other.agreedMonthlyAmount == this.agreedMonthlyAmount &&
          other.userId == this.userId &&
          other.contractDate == this.contractDate &&
          other.isCompleted == this.isCompleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.lastActionDate == this.lastActionDate &&
          other.lastActionNote == this.lastActionNote &&
          other.isDeleted == this.isDeleted &&
          other.isSynced == this.isSynced);
}

class ContractsCompanion extends UpdateCompanion<Contract> {
  final Value<String> id;
  final Value<String> clientId;
  final Value<String?> apartmentId;
  final Value<String> apartmentDetails;
  final Value<String> contractType;
  final Value<double> totalArea;
  final Value<double> baseMeterPriceAtSigning;
  final Value<bool> isPenaltyActive;
  final Value<double> penaltyPercentage;
  final Value<int> penaltyIntervalMonths;
  final Value<double> downPayment;
  final Value<bool> isHandedOver;
  final Value<DateTime?> agreedHandoverDate;
  final Value<DateTime?> actualHandoverDate;
  final Value<int> gracePeriodMonths;
  final Value<String?> handoverNotes;
  final Value<int> installmentsCount;
  final Value<String> coefficients;
  final Value<String> guarantorName;
  final Value<String?> contractFileUrl;
  final Value<double> agreedMonthlyAmount;
  final Value<String> userId;
  final Value<DateTime> contractDate;
  final Value<bool> isCompleted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> lastActionDate;
  final Value<String?> lastActionNote;
  final Value<bool> isDeleted;
  final Value<bool> isSynced;
  final Value<int> rowid;
  const ContractsCompanion({
    this.id = const Value.absent(),
    this.clientId = const Value.absent(),
    this.apartmentId = const Value.absent(),
    this.apartmentDetails = const Value.absent(),
    this.contractType = const Value.absent(),
    this.totalArea = const Value.absent(),
    this.baseMeterPriceAtSigning = const Value.absent(),
    this.isPenaltyActive = const Value.absent(),
    this.penaltyPercentage = const Value.absent(),
    this.penaltyIntervalMonths = const Value.absent(),
    this.downPayment = const Value.absent(),
    this.isHandedOver = const Value.absent(),
    this.agreedHandoverDate = const Value.absent(),
    this.actualHandoverDate = const Value.absent(),
    this.gracePeriodMonths = const Value.absent(),
    this.handoverNotes = const Value.absent(),
    this.installmentsCount = const Value.absent(),
    this.coefficients = const Value.absent(),
    this.guarantorName = const Value.absent(),
    this.contractFileUrl = const Value.absent(),
    this.agreedMonthlyAmount = const Value.absent(),
    this.userId = const Value.absent(),
    this.contractDate = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastActionDate = const Value.absent(),
    this.lastActionNote = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContractsCompanion.insert({
    this.id = const Value.absent(),
    required String clientId,
    this.apartmentId = const Value.absent(),
    this.apartmentDetails = const Value.absent(),
    this.contractType = const Value.absent(),
    required double totalArea,
    required double baseMeterPriceAtSigning,
    this.isPenaltyActive = const Value.absent(),
    this.penaltyPercentage = const Value.absent(),
    this.penaltyIntervalMonths = const Value.absent(),
    this.downPayment = const Value.absent(),
    this.isHandedOver = const Value.absent(),
    this.agreedHandoverDate = const Value.absent(),
    this.actualHandoverDate = const Value.absent(),
    this.gracePeriodMonths = const Value.absent(),
    this.handoverNotes = const Value.absent(),
    this.installmentsCount = const Value.absent(),
    this.coefficients = const Value.absent(),
    required String guarantorName,
    this.contractFileUrl = const Value.absent(),
    this.agreedMonthlyAmount = const Value.absent(),
    required String userId,
    required DateTime contractDate,
    this.isCompleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastActionDate = const Value.absent(),
    this.lastActionNote = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : clientId = Value(clientId),
       totalArea = Value(totalArea),
       baseMeterPriceAtSigning = Value(baseMeterPriceAtSigning),
       guarantorName = Value(guarantorName),
       userId = Value(userId),
       contractDate = Value(contractDate);
  static Insertable<Contract> custom({
    Expression<String>? id,
    Expression<String>? clientId,
    Expression<String>? apartmentId,
    Expression<String>? apartmentDetails,
    Expression<String>? contractType,
    Expression<double>? totalArea,
    Expression<double>? baseMeterPriceAtSigning,
    Expression<bool>? isPenaltyActive,
    Expression<double>? penaltyPercentage,
    Expression<int>? penaltyIntervalMonths,
    Expression<double>? downPayment,
    Expression<bool>? isHandedOver,
    Expression<DateTime>? agreedHandoverDate,
    Expression<DateTime>? actualHandoverDate,
    Expression<int>? gracePeriodMonths,
    Expression<String>? handoverNotes,
    Expression<int>? installmentsCount,
    Expression<String>? coefficients,
    Expression<String>? guarantorName,
    Expression<String>? contractFileUrl,
    Expression<double>? agreedMonthlyAmount,
    Expression<String>? userId,
    Expression<DateTime>? contractDate,
    Expression<bool>? isCompleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? lastActionDate,
    Expression<String>? lastActionNote,
    Expression<bool>? isDeleted,
    Expression<bool>? isSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (clientId != null) 'client_id': clientId,
      if (apartmentId != null) 'apartment_id': apartmentId,
      if (apartmentDetails != null) 'apartment_details': apartmentDetails,
      if (contractType != null) 'contract_type': contractType,
      if (totalArea != null) 'total_area': totalArea,
      if (baseMeterPriceAtSigning != null)
        'base_meter_price_at_signing': baseMeterPriceAtSigning,
      if (isPenaltyActive != null) 'is_penalty_active': isPenaltyActive,
      if (penaltyPercentage != null) 'penalty_percentage': penaltyPercentage,
      if (penaltyIntervalMonths != null)
        'penalty_interval_months': penaltyIntervalMonths,
      if (downPayment != null) 'down_payment': downPayment,
      if (isHandedOver != null) 'is_handed_over': isHandedOver,
      if (agreedHandoverDate != null)
        'agreed_handover_date': agreedHandoverDate,
      if (actualHandoverDate != null)
        'actual_handover_date': actualHandoverDate,
      if (gracePeriodMonths != null) 'grace_period_months': gracePeriodMonths,
      if (handoverNotes != null) 'handover_notes': handoverNotes,
      if (installmentsCount != null) 'installments_count': installmentsCount,
      if (coefficients != null) 'coefficients': coefficients,
      if (guarantorName != null) 'guarantor_name': guarantorName,
      if (contractFileUrl != null) 'contract_file_url': contractFileUrl,
      if (agreedMonthlyAmount != null)
        'agreed_monthly_amount': agreedMonthlyAmount,
      if (userId != null) 'user_id': userId,
      if (contractDate != null) 'contract_date': contractDate,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastActionDate != null) 'last_action_date': lastActionDate,
      if (lastActionNote != null) 'last_action_note': lastActionNote,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isSynced != null) 'is_synced': isSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContractsCompanion copyWith({
    Value<String>? id,
    Value<String>? clientId,
    Value<String?>? apartmentId,
    Value<String>? apartmentDetails,
    Value<String>? contractType,
    Value<double>? totalArea,
    Value<double>? baseMeterPriceAtSigning,
    Value<bool>? isPenaltyActive,
    Value<double>? penaltyPercentage,
    Value<int>? penaltyIntervalMonths,
    Value<double>? downPayment,
    Value<bool>? isHandedOver,
    Value<DateTime?>? agreedHandoverDate,
    Value<DateTime?>? actualHandoverDate,
    Value<int>? gracePeriodMonths,
    Value<String?>? handoverNotes,
    Value<int>? installmentsCount,
    Value<String>? coefficients,
    Value<String>? guarantorName,
    Value<String?>? contractFileUrl,
    Value<double>? agreedMonthlyAmount,
    Value<String>? userId,
    Value<DateTime>? contractDate,
    Value<bool>? isCompleted,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? lastActionDate,
    Value<String?>? lastActionNote,
    Value<bool>? isDeleted,
    Value<bool>? isSynced,
    Value<int>? rowid,
  }) {
    return ContractsCompanion(
      id: id ?? this.id,
      clientId: clientId ?? this.clientId,
      apartmentId: apartmentId ?? this.apartmentId,
      apartmentDetails: apartmentDetails ?? this.apartmentDetails,
      contractType: contractType ?? this.contractType,
      totalArea: totalArea ?? this.totalArea,
      baseMeterPriceAtSigning:
          baseMeterPriceAtSigning ?? this.baseMeterPriceAtSigning,
      isPenaltyActive: isPenaltyActive ?? this.isPenaltyActive,
      penaltyPercentage: penaltyPercentage ?? this.penaltyPercentage,
      penaltyIntervalMonths:
          penaltyIntervalMonths ?? this.penaltyIntervalMonths,
      downPayment: downPayment ?? this.downPayment,
      isHandedOver: isHandedOver ?? this.isHandedOver,
      agreedHandoverDate: agreedHandoverDate ?? this.agreedHandoverDate,
      actualHandoverDate: actualHandoverDate ?? this.actualHandoverDate,
      gracePeriodMonths: gracePeriodMonths ?? this.gracePeriodMonths,
      handoverNotes: handoverNotes ?? this.handoverNotes,
      installmentsCount: installmentsCount ?? this.installmentsCount,
      coefficients: coefficients ?? this.coefficients,
      guarantorName: guarantorName ?? this.guarantorName,
      contractFileUrl: contractFileUrl ?? this.contractFileUrl,
      agreedMonthlyAmount: agreedMonthlyAmount ?? this.agreedMonthlyAmount,
      userId: userId ?? this.userId,
      contractDate: contractDate ?? this.contractDate,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastActionDate: lastActionDate ?? this.lastActionDate,
      lastActionNote: lastActionNote ?? this.lastActionNote,
      isDeleted: isDeleted ?? this.isDeleted,
      isSynced: isSynced ?? this.isSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (apartmentId.present) {
      map['apartment_id'] = Variable<String>(apartmentId.value);
    }
    if (apartmentDetails.present) {
      map['apartment_details'] = Variable<String>(apartmentDetails.value);
    }
    if (contractType.present) {
      map['contract_type'] = Variable<String>(contractType.value);
    }
    if (totalArea.present) {
      map['total_area'] = Variable<double>(totalArea.value);
    }
    if (baseMeterPriceAtSigning.present) {
      map['base_meter_price_at_signing'] = Variable<double>(
        baseMeterPriceAtSigning.value,
      );
    }
    if (isPenaltyActive.present) {
      map['is_penalty_active'] = Variable<bool>(isPenaltyActive.value);
    }
    if (penaltyPercentage.present) {
      map['penalty_percentage'] = Variable<double>(penaltyPercentage.value);
    }
    if (penaltyIntervalMonths.present) {
      map['penalty_interval_months'] = Variable<int>(
        penaltyIntervalMonths.value,
      );
    }
    if (downPayment.present) {
      map['down_payment'] = Variable<double>(downPayment.value);
    }
    if (isHandedOver.present) {
      map['is_handed_over'] = Variable<bool>(isHandedOver.value);
    }
    if (agreedHandoverDate.present) {
      map['agreed_handover_date'] = Variable<DateTime>(
        agreedHandoverDate.value,
      );
    }
    if (actualHandoverDate.present) {
      map['actual_handover_date'] = Variable<DateTime>(
        actualHandoverDate.value,
      );
    }
    if (gracePeriodMonths.present) {
      map['grace_period_months'] = Variable<int>(gracePeriodMonths.value);
    }
    if (handoverNotes.present) {
      map['handover_notes'] = Variable<String>(handoverNotes.value);
    }
    if (installmentsCount.present) {
      map['installments_count'] = Variable<int>(installmentsCount.value);
    }
    if (coefficients.present) {
      map['coefficients'] = Variable<String>(coefficients.value);
    }
    if (guarantorName.present) {
      map['guarantor_name'] = Variable<String>(guarantorName.value);
    }
    if (contractFileUrl.present) {
      map['contract_file_url'] = Variable<String>(contractFileUrl.value);
    }
    if (agreedMonthlyAmount.present) {
      map['agreed_monthly_amount'] = Variable<double>(
        agreedMonthlyAmount.value,
      );
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (contractDate.present) {
      map['contract_date'] = Variable<DateTime>(contractDate.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (lastActionDate.present) {
      map['last_action_date'] = Variable<DateTime>(lastActionDate.value);
    }
    if (lastActionNote.present) {
      map['last_action_note'] = Variable<String>(lastActionNote.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContractsCompanion(')
          ..write('id: $id, ')
          ..write('clientId: $clientId, ')
          ..write('apartmentId: $apartmentId, ')
          ..write('apartmentDetails: $apartmentDetails, ')
          ..write('contractType: $contractType, ')
          ..write('totalArea: $totalArea, ')
          ..write('baseMeterPriceAtSigning: $baseMeterPriceAtSigning, ')
          ..write('isPenaltyActive: $isPenaltyActive, ')
          ..write('penaltyPercentage: $penaltyPercentage, ')
          ..write('penaltyIntervalMonths: $penaltyIntervalMonths, ')
          ..write('downPayment: $downPayment, ')
          ..write('isHandedOver: $isHandedOver, ')
          ..write('agreedHandoverDate: $agreedHandoverDate, ')
          ..write('actualHandoverDate: $actualHandoverDate, ')
          ..write('gracePeriodMonths: $gracePeriodMonths, ')
          ..write('handoverNotes: $handoverNotes, ')
          ..write('installmentsCount: $installmentsCount, ')
          ..write('coefficients: $coefficients, ')
          ..write('guarantorName: $guarantorName, ')
          ..write('contractFileUrl: $contractFileUrl, ')
          ..write('agreedMonthlyAmount: $agreedMonthlyAmount, ')
          ..write('userId: $userId, ')
          ..write('contractDate: $contractDate, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastActionDate: $lastActionDate, ')
          ..write('lastActionNote: $lastActionNote, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isSynced: $isSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MaterialPricesHistoryTable extends MaterialPricesHistory
    with TableInfo<$MaterialPricesHistoryTable, MaterialPricesHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MaterialPricesHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v7(),
  );
  static const VerificationMeta _effectiveDateMeta = const VerificationMeta(
    'effectiveDate',
  );
  @override
  late final GeneratedColumn<DateTime> effectiveDate =
      GeneratedColumn<DateTime>(
        'effective_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        clientDefault: () => DateTime.now().toUtc(),
      );
  static const VerificationMeta _ironPriceMeta = const VerificationMeta(
    'ironPrice',
  );
  @override
  late final GeneratedColumn<double> ironPrice = GeneratedColumn<double>(
    'iron_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cementPriceMeta = const VerificationMeta(
    'cementPrice',
  );
  @override
  late final GeneratedColumn<double> cementPrice = GeneratedColumn<double>(
    'cement_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _block15PriceMeta = const VerificationMeta(
    'block15Price',
  );
  @override
  late final GeneratedColumn<double> block15Price = GeneratedColumn<double>(
    'block15_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _formworkAndPouringWagesMeta =
      const VerificationMeta('formworkAndPouringWages');
  @override
  late final GeneratedColumn<double> formworkAndPouringWages =
      GeneratedColumn<double>(
        'formwork_and_pouring_wages',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _aggregateMaterialsPriceMeta =
      const VerificationMeta('aggregateMaterialsPrice');
  @override
  late final GeneratedColumn<double> aggregateMaterialsPrice =
      GeneratedColumn<double>(
        'aggregate_materials_price',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _ordinaryWorkerWageMeta =
      const VerificationMeta('ordinaryWorkerWage');
  @override
  late final GeneratedColumn<double> ordinaryWorkerWage =
      GeneratedColumn<double>(
        'ordinary_worker_wage',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    effectiveDate,
    ironPrice,
    cementPrice,
    block15Price,
    formworkAndPouringWages,
    aggregateMaterialsPrice,
    ordinaryWorkerWage,
    userId,
    createdAt,
    updatedAt,
    isDeleted,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'material_prices_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<MaterialPricesHistoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('effective_date')) {
      context.handle(
        _effectiveDateMeta,
        effectiveDate.isAcceptableOrUnknown(
          data['effective_date']!,
          _effectiveDateMeta,
        ),
      );
    }
    if (data.containsKey('iron_price')) {
      context.handle(
        _ironPriceMeta,
        ironPrice.isAcceptableOrUnknown(data['iron_price']!, _ironPriceMeta),
      );
    } else if (isInserting) {
      context.missing(_ironPriceMeta);
    }
    if (data.containsKey('cement_price')) {
      context.handle(
        _cementPriceMeta,
        cementPrice.isAcceptableOrUnknown(
          data['cement_price']!,
          _cementPriceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_cementPriceMeta);
    }
    if (data.containsKey('block15_price')) {
      context.handle(
        _block15PriceMeta,
        block15Price.isAcceptableOrUnknown(
          data['block15_price']!,
          _block15PriceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_block15PriceMeta);
    }
    if (data.containsKey('formwork_and_pouring_wages')) {
      context.handle(
        _formworkAndPouringWagesMeta,
        formworkAndPouringWages.isAcceptableOrUnknown(
          data['formwork_and_pouring_wages']!,
          _formworkAndPouringWagesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_formworkAndPouringWagesMeta);
    }
    if (data.containsKey('aggregate_materials_price')) {
      context.handle(
        _aggregateMaterialsPriceMeta,
        aggregateMaterialsPrice.isAcceptableOrUnknown(
          data['aggregate_materials_price']!,
          _aggregateMaterialsPriceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_aggregateMaterialsPriceMeta);
    }
    if (data.containsKey('ordinary_worker_wage')) {
      context.handle(
        _ordinaryWorkerWageMeta,
        ordinaryWorkerWage.isAcceptableOrUnknown(
          data['ordinary_worker_wage']!,
          _ordinaryWorkerWageMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_ordinaryWorkerWageMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MaterialPricesHistoryData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MaterialPricesHistoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      effectiveDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}effective_date'],
      )!,
      ironPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}iron_price'],
      )!,
      cementPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cement_price'],
      )!,
      block15Price: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}block15_price'],
      )!,
      formworkAndPouringWages: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}formwork_and_pouring_wages'],
      )!,
      aggregateMaterialsPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}aggregate_materials_price'],
      )!,
      ordinaryWorkerWage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}ordinary_worker_wage'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  $MaterialPricesHistoryTable createAlias(String alias) {
    return $MaterialPricesHistoryTable(attachedDatabase, alias);
  }
}

class MaterialPricesHistoryData extends DataClass
    implements Insertable<MaterialPricesHistoryData> {
  final String id;
  final DateTime effectiveDate;
  final double ironPrice;
  final double cementPrice;
  final double block15Price;
  final double formworkAndPouringWages;
  final double aggregateMaterialsPrice;
  final double ordinaryWorkerWage;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final bool isSynced;
  const MaterialPricesHistoryData({
    required this.id,
    required this.effectiveDate,
    required this.ironPrice,
    required this.cementPrice,
    required this.block15Price,
    required this.formworkAndPouringWages,
    required this.aggregateMaterialsPrice,
    required this.ordinaryWorkerWage,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['effective_date'] = Variable<DateTime>(effectiveDate);
    map['iron_price'] = Variable<double>(ironPrice);
    map['cement_price'] = Variable<double>(cementPrice);
    map['block15_price'] = Variable<double>(block15Price);
    map['formwork_and_pouring_wages'] = Variable<double>(
      formworkAndPouringWages,
    );
    map['aggregate_materials_price'] = Variable<double>(
      aggregateMaterialsPrice,
    );
    map['ordinary_worker_wage'] = Variable<double>(ordinaryWorkerWage);
    map['user_id'] = Variable<String>(userId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  MaterialPricesHistoryCompanion toCompanion(bool nullToAbsent) {
    return MaterialPricesHistoryCompanion(
      id: Value(id),
      effectiveDate: Value(effectiveDate),
      ironPrice: Value(ironPrice),
      cementPrice: Value(cementPrice),
      block15Price: Value(block15Price),
      formworkAndPouringWages: Value(formworkAndPouringWages),
      aggregateMaterialsPrice: Value(aggregateMaterialsPrice),
      ordinaryWorkerWage: Value(ordinaryWorkerWage),
      userId: Value(userId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      isSynced: Value(isSynced),
    );
  }

  factory MaterialPricesHistoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MaterialPricesHistoryData(
      id: serializer.fromJson<String>(json['id']),
      effectiveDate: serializer.fromJson<DateTime>(json['effectiveDate']),
      ironPrice: serializer.fromJson<double>(json['ironPrice']),
      cementPrice: serializer.fromJson<double>(json['cementPrice']),
      block15Price: serializer.fromJson<double>(json['block15Price']),
      formworkAndPouringWages: serializer.fromJson<double>(
        json['formworkAndPouringWages'],
      ),
      aggregateMaterialsPrice: serializer.fromJson<double>(
        json['aggregateMaterialsPrice'],
      ),
      ordinaryWorkerWage: serializer.fromJson<double>(
        json['ordinaryWorkerWage'],
      ),
      userId: serializer.fromJson<String>(json['userId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'effectiveDate': serializer.toJson<DateTime>(effectiveDate),
      'ironPrice': serializer.toJson<double>(ironPrice),
      'cementPrice': serializer.toJson<double>(cementPrice),
      'block15Price': serializer.toJson<double>(block15Price),
      'formworkAndPouringWages': serializer.toJson<double>(
        formworkAndPouringWages,
      ),
      'aggregateMaterialsPrice': serializer.toJson<double>(
        aggregateMaterialsPrice,
      ),
      'ordinaryWorkerWage': serializer.toJson<double>(ordinaryWorkerWage),
      'userId': serializer.toJson<String>(userId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  MaterialPricesHistoryData copyWith({
    String? id,
    DateTime? effectiveDate,
    double? ironPrice,
    double? cementPrice,
    double? block15Price,
    double? formworkAndPouringWages,
    double? aggregateMaterialsPrice,
    double? ordinaryWorkerWage,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    bool? isSynced,
  }) => MaterialPricesHistoryData(
    id: id ?? this.id,
    effectiveDate: effectiveDate ?? this.effectiveDate,
    ironPrice: ironPrice ?? this.ironPrice,
    cementPrice: cementPrice ?? this.cementPrice,
    block15Price: block15Price ?? this.block15Price,
    formworkAndPouringWages:
        formworkAndPouringWages ?? this.formworkAndPouringWages,
    aggregateMaterialsPrice:
        aggregateMaterialsPrice ?? this.aggregateMaterialsPrice,
    ordinaryWorkerWage: ordinaryWorkerWage ?? this.ordinaryWorkerWage,
    userId: userId ?? this.userId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
    isSynced: isSynced ?? this.isSynced,
  );
  MaterialPricesHistoryData copyWithCompanion(
    MaterialPricesHistoryCompanion data,
  ) {
    return MaterialPricesHistoryData(
      id: data.id.present ? data.id.value : this.id,
      effectiveDate: data.effectiveDate.present
          ? data.effectiveDate.value
          : this.effectiveDate,
      ironPrice: data.ironPrice.present ? data.ironPrice.value : this.ironPrice,
      cementPrice: data.cementPrice.present
          ? data.cementPrice.value
          : this.cementPrice,
      block15Price: data.block15Price.present
          ? data.block15Price.value
          : this.block15Price,
      formworkAndPouringWages: data.formworkAndPouringWages.present
          ? data.formworkAndPouringWages.value
          : this.formworkAndPouringWages,
      aggregateMaterialsPrice: data.aggregateMaterialsPrice.present
          ? data.aggregateMaterialsPrice.value
          : this.aggregateMaterialsPrice,
      ordinaryWorkerWage: data.ordinaryWorkerWage.present
          ? data.ordinaryWorkerWage.value
          : this.ordinaryWorkerWage,
      userId: data.userId.present ? data.userId.value : this.userId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MaterialPricesHistoryData(')
          ..write('id: $id, ')
          ..write('effectiveDate: $effectiveDate, ')
          ..write('ironPrice: $ironPrice, ')
          ..write('cementPrice: $cementPrice, ')
          ..write('block15Price: $block15Price, ')
          ..write('formworkAndPouringWages: $formworkAndPouringWages, ')
          ..write('aggregateMaterialsPrice: $aggregateMaterialsPrice, ')
          ..write('ordinaryWorkerWage: $ordinaryWorkerWage, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    effectiveDate,
    ironPrice,
    cementPrice,
    block15Price,
    formworkAndPouringWages,
    aggregateMaterialsPrice,
    ordinaryWorkerWage,
    userId,
    createdAt,
    updatedAt,
    isDeleted,
    isSynced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MaterialPricesHistoryData &&
          other.id == this.id &&
          other.effectiveDate == this.effectiveDate &&
          other.ironPrice == this.ironPrice &&
          other.cementPrice == this.cementPrice &&
          other.block15Price == this.block15Price &&
          other.formworkAndPouringWages == this.formworkAndPouringWages &&
          other.aggregateMaterialsPrice == this.aggregateMaterialsPrice &&
          other.ordinaryWorkerWage == this.ordinaryWorkerWage &&
          other.userId == this.userId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.isSynced == this.isSynced);
}

class MaterialPricesHistoryCompanion
    extends UpdateCompanion<MaterialPricesHistoryData> {
  final Value<String> id;
  final Value<DateTime> effectiveDate;
  final Value<double> ironPrice;
  final Value<double> cementPrice;
  final Value<double> block15Price;
  final Value<double> formworkAndPouringWages;
  final Value<double> aggregateMaterialsPrice;
  final Value<double> ordinaryWorkerWage;
  final Value<String> userId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<bool> isSynced;
  final Value<int> rowid;
  const MaterialPricesHistoryCompanion({
    this.id = const Value.absent(),
    this.effectiveDate = const Value.absent(),
    this.ironPrice = const Value.absent(),
    this.cementPrice = const Value.absent(),
    this.block15Price = const Value.absent(),
    this.formworkAndPouringWages = const Value.absent(),
    this.aggregateMaterialsPrice = const Value.absent(),
    this.ordinaryWorkerWage = const Value.absent(),
    this.userId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MaterialPricesHistoryCompanion.insert({
    this.id = const Value.absent(),
    this.effectiveDate = const Value.absent(),
    required double ironPrice,
    required double cementPrice,
    required double block15Price,
    required double formworkAndPouringWages,
    required double aggregateMaterialsPrice,
    required double ordinaryWorkerWage,
    required String userId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : ironPrice = Value(ironPrice),
       cementPrice = Value(cementPrice),
       block15Price = Value(block15Price),
       formworkAndPouringWages = Value(formworkAndPouringWages),
       aggregateMaterialsPrice = Value(aggregateMaterialsPrice),
       ordinaryWorkerWage = Value(ordinaryWorkerWage),
       userId = Value(userId);
  static Insertable<MaterialPricesHistoryData> custom({
    Expression<String>? id,
    Expression<DateTime>? effectiveDate,
    Expression<double>? ironPrice,
    Expression<double>? cementPrice,
    Expression<double>? block15Price,
    Expression<double>? formworkAndPouringWages,
    Expression<double>? aggregateMaterialsPrice,
    Expression<double>? ordinaryWorkerWage,
    Expression<String>? userId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<bool>? isSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (effectiveDate != null) 'effective_date': effectiveDate,
      if (ironPrice != null) 'iron_price': ironPrice,
      if (cementPrice != null) 'cement_price': cementPrice,
      if (block15Price != null) 'block15_price': block15Price,
      if (formworkAndPouringWages != null)
        'formwork_and_pouring_wages': formworkAndPouringWages,
      if (aggregateMaterialsPrice != null)
        'aggregate_materials_price': aggregateMaterialsPrice,
      if (ordinaryWorkerWage != null)
        'ordinary_worker_wage': ordinaryWorkerWage,
      if (userId != null) 'user_id': userId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isSynced != null) 'is_synced': isSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MaterialPricesHistoryCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? effectiveDate,
    Value<double>? ironPrice,
    Value<double>? cementPrice,
    Value<double>? block15Price,
    Value<double>? formworkAndPouringWages,
    Value<double>? aggregateMaterialsPrice,
    Value<double>? ordinaryWorkerWage,
    Value<String>? userId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isDeleted,
    Value<bool>? isSynced,
    Value<int>? rowid,
  }) {
    return MaterialPricesHistoryCompanion(
      id: id ?? this.id,
      effectiveDate: effectiveDate ?? this.effectiveDate,
      ironPrice: ironPrice ?? this.ironPrice,
      cementPrice: cementPrice ?? this.cementPrice,
      block15Price: block15Price ?? this.block15Price,
      formworkAndPouringWages:
          formworkAndPouringWages ?? this.formworkAndPouringWages,
      aggregateMaterialsPrice:
          aggregateMaterialsPrice ?? this.aggregateMaterialsPrice,
      ordinaryWorkerWage: ordinaryWorkerWage ?? this.ordinaryWorkerWage,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      isSynced: isSynced ?? this.isSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (effectiveDate.present) {
      map['effective_date'] = Variable<DateTime>(effectiveDate.value);
    }
    if (ironPrice.present) {
      map['iron_price'] = Variable<double>(ironPrice.value);
    }
    if (cementPrice.present) {
      map['cement_price'] = Variable<double>(cementPrice.value);
    }
    if (block15Price.present) {
      map['block15_price'] = Variable<double>(block15Price.value);
    }
    if (formworkAndPouringWages.present) {
      map['formwork_and_pouring_wages'] = Variable<double>(
        formworkAndPouringWages.value,
      );
    }
    if (aggregateMaterialsPrice.present) {
      map['aggregate_materials_price'] = Variable<double>(
        aggregateMaterialsPrice.value,
      );
    }
    if (ordinaryWorkerWage.present) {
      map['ordinary_worker_wage'] = Variable<double>(ordinaryWorkerWage.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MaterialPricesHistoryCompanion(')
          ..write('id: $id, ')
          ..write('effectiveDate: $effectiveDate, ')
          ..write('ironPrice: $ironPrice, ')
          ..write('cementPrice: $cementPrice, ')
          ..write('block15Price: $block15Price, ')
          ..write('formworkAndPouringWages: $formworkAndPouringWages, ')
          ..write('aggregateMaterialsPrice: $aggregateMaterialsPrice, ')
          ..write('ordinaryWorkerWage: $ordinaryWorkerWage, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isSynced: $isSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InstallmentsScheduleTable extends InstallmentsSchedule
    with TableInfo<$InstallmentsScheduleTable, InstallmentsScheduleData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InstallmentsScheduleTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v7(),
  );
  static const VerificationMeta _contractIdMeta = const VerificationMeta(
    'contractId',
  );
  @override
  late final GeneratedColumn<String> contractId = GeneratedColumn<String>(
    'contract_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES contracts (id)',
    ),
  );
  static const VerificationMeta _installmentNumberMeta = const VerificationMeta(
    'installmentNumber',
  );
  @override
  late final GeneratedColumn<int> installmentNumber = GeneratedColumn<int>(
    'installment_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    contractId,
    installmentNumber,
    dueDate,
    status,
    notes,
    userId,
    createdAt,
    updatedAt,
    isDeleted,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'installments_schedule';
  @override
  VerificationContext validateIntegrity(
    Insertable<InstallmentsScheduleData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('contract_id')) {
      context.handle(
        _contractIdMeta,
        contractId.isAcceptableOrUnknown(data['contract_id']!, _contractIdMeta),
      );
    } else if (isInserting) {
      context.missing(_contractIdMeta);
    }
    if (data.containsKey('installment_number')) {
      context.handle(
        _installmentNumberMeta,
        installmentNumber.isAcceptableOrUnknown(
          data['installment_number']!,
          _installmentNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_installmentNumberMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    } else if (isInserting) {
      context.missing(_dueDateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InstallmentsScheduleData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InstallmentsScheduleData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      contractId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contract_id'],
      )!,
      installmentNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}installment_number'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  $InstallmentsScheduleTable createAlias(String alias) {
    return $InstallmentsScheduleTable(attachedDatabase, alias);
  }
}

class InstallmentsScheduleData extends DataClass
    implements Insertable<InstallmentsScheduleData> {
  final String id;
  final String contractId;
  final int installmentNumber;
  final DateTime dueDate;
  final String status;
  final String? notes;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final bool isSynced;
  const InstallmentsScheduleData({
    required this.id,
    required this.contractId,
    required this.installmentNumber,
    required this.dueDate,
    required this.status,
    this.notes,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['contract_id'] = Variable<String>(contractId);
    map['installment_number'] = Variable<int>(installmentNumber);
    map['due_date'] = Variable<DateTime>(dueDate);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['user_id'] = Variable<String>(userId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  InstallmentsScheduleCompanion toCompanion(bool nullToAbsent) {
    return InstallmentsScheduleCompanion(
      id: Value(id),
      contractId: Value(contractId),
      installmentNumber: Value(installmentNumber),
      dueDate: Value(dueDate),
      status: Value(status),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      userId: Value(userId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      isSynced: Value(isSynced),
    );
  }

  factory InstallmentsScheduleData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InstallmentsScheduleData(
      id: serializer.fromJson<String>(json['id']),
      contractId: serializer.fromJson<String>(json['contractId']),
      installmentNumber: serializer.fromJson<int>(json['installmentNumber']),
      dueDate: serializer.fromJson<DateTime>(json['dueDate']),
      status: serializer.fromJson<String>(json['status']),
      notes: serializer.fromJson<String?>(json['notes']),
      userId: serializer.fromJson<String>(json['userId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'contractId': serializer.toJson<String>(contractId),
      'installmentNumber': serializer.toJson<int>(installmentNumber),
      'dueDate': serializer.toJson<DateTime>(dueDate),
      'status': serializer.toJson<String>(status),
      'notes': serializer.toJson<String?>(notes),
      'userId': serializer.toJson<String>(userId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  InstallmentsScheduleData copyWith({
    String? id,
    String? contractId,
    int? installmentNumber,
    DateTime? dueDate,
    String? status,
    Value<String?> notes = const Value.absent(),
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    bool? isSynced,
  }) => InstallmentsScheduleData(
    id: id ?? this.id,
    contractId: contractId ?? this.contractId,
    installmentNumber: installmentNumber ?? this.installmentNumber,
    dueDate: dueDate ?? this.dueDate,
    status: status ?? this.status,
    notes: notes.present ? notes.value : this.notes,
    userId: userId ?? this.userId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
    isSynced: isSynced ?? this.isSynced,
  );
  InstallmentsScheduleData copyWithCompanion(
    InstallmentsScheduleCompanion data,
  ) {
    return InstallmentsScheduleData(
      id: data.id.present ? data.id.value : this.id,
      contractId: data.contractId.present
          ? data.contractId.value
          : this.contractId,
      installmentNumber: data.installmentNumber.present
          ? data.installmentNumber.value
          : this.installmentNumber,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      status: data.status.present ? data.status.value : this.status,
      notes: data.notes.present ? data.notes.value : this.notes,
      userId: data.userId.present ? data.userId.value : this.userId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InstallmentsScheduleData(')
          ..write('id: $id, ')
          ..write('contractId: $contractId, ')
          ..write('installmentNumber: $installmentNumber, ')
          ..write('dueDate: $dueDate, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    contractId,
    installmentNumber,
    dueDate,
    status,
    notes,
    userId,
    createdAt,
    updatedAt,
    isDeleted,
    isSynced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InstallmentsScheduleData &&
          other.id == this.id &&
          other.contractId == this.contractId &&
          other.installmentNumber == this.installmentNumber &&
          other.dueDate == this.dueDate &&
          other.status == this.status &&
          other.notes == this.notes &&
          other.userId == this.userId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.isSynced == this.isSynced);
}

class InstallmentsScheduleCompanion
    extends UpdateCompanion<InstallmentsScheduleData> {
  final Value<String> id;
  final Value<String> contractId;
  final Value<int> installmentNumber;
  final Value<DateTime> dueDate;
  final Value<String> status;
  final Value<String?> notes;
  final Value<String> userId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<bool> isSynced;
  final Value<int> rowid;
  const InstallmentsScheduleCompanion({
    this.id = const Value.absent(),
    this.contractId = const Value.absent(),
    this.installmentNumber = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.userId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InstallmentsScheduleCompanion.insert({
    this.id = const Value.absent(),
    required String contractId,
    required int installmentNumber,
    required DateTime dueDate,
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    required String userId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : contractId = Value(contractId),
       installmentNumber = Value(installmentNumber),
       dueDate = Value(dueDate),
       userId = Value(userId);
  static Insertable<InstallmentsScheduleData> custom({
    Expression<String>? id,
    Expression<String>? contractId,
    Expression<int>? installmentNumber,
    Expression<DateTime>? dueDate,
    Expression<String>? status,
    Expression<String>? notes,
    Expression<String>? userId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<bool>? isSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (contractId != null) 'contract_id': contractId,
      if (installmentNumber != null) 'installment_number': installmentNumber,
      if (dueDate != null) 'due_date': dueDate,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
      if (userId != null) 'user_id': userId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isSynced != null) 'is_synced': isSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InstallmentsScheduleCompanion copyWith({
    Value<String>? id,
    Value<String>? contractId,
    Value<int>? installmentNumber,
    Value<DateTime>? dueDate,
    Value<String>? status,
    Value<String?>? notes,
    Value<String>? userId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isDeleted,
    Value<bool>? isSynced,
    Value<int>? rowid,
  }) {
    return InstallmentsScheduleCompanion(
      id: id ?? this.id,
      contractId: contractId ?? this.contractId,
      installmentNumber: installmentNumber ?? this.installmentNumber,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      isSynced: isSynced ?? this.isSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (contractId.present) {
      map['contract_id'] = Variable<String>(contractId.value);
    }
    if (installmentNumber.present) {
      map['installment_number'] = Variable<int>(installmentNumber.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InstallmentsScheduleCompanion(')
          ..write('id: $id, ')
          ..write('contractId: $contractId, ')
          ..write('installmentNumber: $installmentNumber, ')
          ..write('dueDate: $dueDate, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isSynced: $isSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PaymentsLedgerTable extends PaymentsLedger
    with TableInfo<$PaymentsLedgerTable, PaymentsLedgerData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentsLedgerTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v7(),
  );
  static const VerificationMeta _contractIdMeta = const VerificationMeta(
    'contractId',
  );
  @override
  late final GeneratedColumn<String> contractId = GeneratedColumn<String>(
    'contract_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES contracts (id)',
    ),
  );
  static const VerificationMeta _scheduleIdMeta = const VerificationMeta(
    'scheduleId',
  );
  @override
  late final GeneratedColumn<String> scheduleId = GeneratedColumn<String>(
    'schedule_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES installments_schedule (id)',
    ),
  );
  static const VerificationMeta _paymentDateMeta = const VerificationMeta(
    'paymentDate',
  );
  @override
  late final GeneratedColumn<DateTime> paymentDate = GeneratedColumn<DateTime>(
    'payment_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountPaidMeta = const VerificationMeta(
    'amountPaid',
  );
  @override
  late final GeneratedColumn<double> amountPaid = GeneratedColumn<double>(
    'amount_paid',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _meterPriceAtPaymentMeta =
      const VerificationMeta('meterPriceAtPayment');
  @override
  late final GeneratedColumn<double> meterPriceAtPayment =
      GeneratedColumn<double>(
        'meter_price_at_payment',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _convertedMetersMeta = const VerificationMeta(
    'convertedMeters',
  );
  @override
  late final GeneratedColumn<double> convertedMeters = GeneratedColumn<double>(
    'converted_meters',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pricesSnapshotMeta = const VerificationMeta(
    'pricesSnapshot',
  );
  @override
  late final GeneratedColumn<String> pricesSnapshot = GeneratedColumn<String>(
    'prices_snapshot',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _feesMeta = const VerificationMeta('fees');
  @override
  late final GeneratedColumn<double> fees = GeneratedColumn<double>(
    'fees',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isWhatsAppSentMeta = const VerificationMeta(
    'isWhatsAppSent',
  );
  @override
  late final GeneratedColumn<bool> isWhatsAppSent = GeneratedColumn<bool>(
    'is_whats_app_sent',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_whats_app_sent" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    contractId,
    scheduleId,
    paymentDate,
    amountPaid,
    meterPriceAtPayment,
    convertedMeters,
    pricesSnapshot,
    fees,
    isWhatsAppSent,
    userId,
    createdAt,
    updatedAt,
    isDeleted,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payments_ledger';
  @override
  VerificationContext validateIntegrity(
    Insertable<PaymentsLedgerData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('contract_id')) {
      context.handle(
        _contractIdMeta,
        contractId.isAcceptableOrUnknown(data['contract_id']!, _contractIdMeta),
      );
    } else if (isInserting) {
      context.missing(_contractIdMeta);
    }
    if (data.containsKey('schedule_id')) {
      context.handle(
        _scheduleIdMeta,
        scheduleId.isAcceptableOrUnknown(data['schedule_id']!, _scheduleIdMeta),
      );
    }
    if (data.containsKey('payment_date')) {
      context.handle(
        _paymentDateMeta,
        paymentDate.isAcceptableOrUnknown(
          data['payment_date']!,
          _paymentDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentDateMeta);
    }
    if (data.containsKey('amount_paid')) {
      context.handle(
        _amountPaidMeta,
        amountPaid.isAcceptableOrUnknown(data['amount_paid']!, _amountPaidMeta),
      );
    } else if (isInserting) {
      context.missing(_amountPaidMeta);
    }
    if (data.containsKey('meter_price_at_payment')) {
      context.handle(
        _meterPriceAtPaymentMeta,
        meterPriceAtPayment.isAcceptableOrUnknown(
          data['meter_price_at_payment']!,
          _meterPriceAtPaymentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_meterPriceAtPaymentMeta);
    }
    if (data.containsKey('converted_meters')) {
      context.handle(
        _convertedMetersMeta,
        convertedMeters.isAcceptableOrUnknown(
          data['converted_meters']!,
          _convertedMetersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_convertedMetersMeta);
    }
    if (data.containsKey('prices_snapshot')) {
      context.handle(
        _pricesSnapshotMeta,
        pricesSnapshot.isAcceptableOrUnknown(
          data['prices_snapshot']!,
          _pricesSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('fees')) {
      context.handle(
        _feesMeta,
        fees.isAcceptableOrUnknown(data['fees']!, _feesMeta),
      );
    }
    if (data.containsKey('is_whats_app_sent')) {
      context.handle(
        _isWhatsAppSentMeta,
        isWhatsAppSent.isAcceptableOrUnknown(
          data['is_whats_app_sent']!,
          _isWhatsAppSentMeta,
        ),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PaymentsLedgerData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PaymentsLedgerData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      contractId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contract_id'],
      )!,
      scheduleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}schedule_id'],
      ),
      paymentDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}payment_date'],
      )!,
      amountPaid: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount_paid'],
      )!,
      meterPriceAtPayment: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}meter_price_at_payment'],
      )!,
      convertedMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}converted_meters'],
      )!,
      pricesSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prices_snapshot'],
      )!,
      fees: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fees'],
      )!,
      isWhatsAppSent: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_whats_app_sent'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  $PaymentsLedgerTable createAlias(String alias) {
    return $PaymentsLedgerTable(attachedDatabase, alias);
  }
}

class PaymentsLedgerData extends DataClass
    implements Insertable<PaymentsLedgerData> {
  final String id;
  final String contractId;
  final String? scheduleId;
  final DateTime paymentDate;
  final double amountPaid;
  final double meterPriceAtPayment;
  final double convertedMeters;
  final String pricesSnapshot;
  final double fees;
  final bool isWhatsAppSent;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final bool isSynced;
  const PaymentsLedgerData({
    required this.id,
    required this.contractId,
    this.scheduleId,
    required this.paymentDate,
    required this.amountPaid,
    required this.meterPriceAtPayment,
    required this.convertedMeters,
    required this.pricesSnapshot,
    required this.fees,
    required this.isWhatsAppSent,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['contract_id'] = Variable<String>(contractId);
    if (!nullToAbsent || scheduleId != null) {
      map['schedule_id'] = Variable<String>(scheduleId);
    }
    map['payment_date'] = Variable<DateTime>(paymentDate);
    map['amount_paid'] = Variable<double>(amountPaid);
    map['meter_price_at_payment'] = Variable<double>(meterPriceAtPayment);
    map['converted_meters'] = Variable<double>(convertedMeters);
    map['prices_snapshot'] = Variable<String>(pricesSnapshot);
    map['fees'] = Variable<double>(fees);
    map['is_whats_app_sent'] = Variable<bool>(isWhatsAppSent);
    map['user_id'] = Variable<String>(userId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  PaymentsLedgerCompanion toCompanion(bool nullToAbsent) {
    return PaymentsLedgerCompanion(
      id: Value(id),
      contractId: Value(contractId),
      scheduleId: scheduleId == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduleId),
      paymentDate: Value(paymentDate),
      amountPaid: Value(amountPaid),
      meterPriceAtPayment: Value(meterPriceAtPayment),
      convertedMeters: Value(convertedMeters),
      pricesSnapshot: Value(pricesSnapshot),
      fees: Value(fees),
      isWhatsAppSent: Value(isWhatsAppSent),
      userId: Value(userId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      isSynced: Value(isSynced),
    );
  }

  factory PaymentsLedgerData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PaymentsLedgerData(
      id: serializer.fromJson<String>(json['id']),
      contractId: serializer.fromJson<String>(json['contractId']),
      scheduleId: serializer.fromJson<String?>(json['scheduleId']),
      paymentDate: serializer.fromJson<DateTime>(json['paymentDate']),
      amountPaid: serializer.fromJson<double>(json['amountPaid']),
      meterPriceAtPayment: serializer.fromJson<double>(
        json['meterPriceAtPayment'],
      ),
      convertedMeters: serializer.fromJson<double>(json['convertedMeters']),
      pricesSnapshot: serializer.fromJson<String>(json['pricesSnapshot']),
      fees: serializer.fromJson<double>(json['fees']),
      isWhatsAppSent: serializer.fromJson<bool>(json['isWhatsAppSent']),
      userId: serializer.fromJson<String>(json['userId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'contractId': serializer.toJson<String>(contractId),
      'scheduleId': serializer.toJson<String?>(scheduleId),
      'paymentDate': serializer.toJson<DateTime>(paymentDate),
      'amountPaid': serializer.toJson<double>(amountPaid),
      'meterPriceAtPayment': serializer.toJson<double>(meterPriceAtPayment),
      'convertedMeters': serializer.toJson<double>(convertedMeters),
      'pricesSnapshot': serializer.toJson<String>(pricesSnapshot),
      'fees': serializer.toJson<double>(fees),
      'isWhatsAppSent': serializer.toJson<bool>(isWhatsAppSent),
      'userId': serializer.toJson<String>(userId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  PaymentsLedgerData copyWith({
    String? id,
    String? contractId,
    Value<String?> scheduleId = const Value.absent(),
    DateTime? paymentDate,
    double? amountPaid,
    double? meterPriceAtPayment,
    double? convertedMeters,
    String? pricesSnapshot,
    double? fees,
    bool? isWhatsAppSent,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    bool? isSynced,
  }) => PaymentsLedgerData(
    id: id ?? this.id,
    contractId: contractId ?? this.contractId,
    scheduleId: scheduleId.present ? scheduleId.value : this.scheduleId,
    paymentDate: paymentDate ?? this.paymentDate,
    amountPaid: amountPaid ?? this.amountPaid,
    meterPriceAtPayment: meterPriceAtPayment ?? this.meterPriceAtPayment,
    convertedMeters: convertedMeters ?? this.convertedMeters,
    pricesSnapshot: pricesSnapshot ?? this.pricesSnapshot,
    fees: fees ?? this.fees,
    isWhatsAppSent: isWhatsAppSent ?? this.isWhatsAppSent,
    userId: userId ?? this.userId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
    isSynced: isSynced ?? this.isSynced,
  );
  PaymentsLedgerData copyWithCompanion(PaymentsLedgerCompanion data) {
    return PaymentsLedgerData(
      id: data.id.present ? data.id.value : this.id,
      contractId: data.contractId.present
          ? data.contractId.value
          : this.contractId,
      scheduleId: data.scheduleId.present
          ? data.scheduleId.value
          : this.scheduleId,
      paymentDate: data.paymentDate.present
          ? data.paymentDate.value
          : this.paymentDate,
      amountPaid: data.amountPaid.present
          ? data.amountPaid.value
          : this.amountPaid,
      meterPriceAtPayment: data.meterPriceAtPayment.present
          ? data.meterPriceAtPayment.value
          : this.meterPriceAtPayment,
      convertedMeters: data.convertedMeters.present
          ? data.convertedMeters.value
          : this.convertedMeters,
      pricesSnapshot: data.pricesSnapshot.present
          ? data.pricesSnapshot.value
          : this.pricesSnapshot,
      fees: data.fees.present ? data.fees.value : this.fees,
      isWhatsAppSent: data.isWhatsAppSent.present
          ? data.isWhatsAppSent.value
          : this.isWhatsAppSent,
      userId: data.userId.present ? data.userId.value : this.userId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PaymentsLedgerData(')
          ..write('id: $id, ')
          ..write('contractId: $contractId, ')
          ..write('scheduleId: $scheduleId, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('amountPaid: $amountPaid, ')
          ..write('meterPriceAtPayment: $meterPriceAtPayment, ')
          ..write('convertedMeters: $convertedMeters, ')
          ..write('pricesSnapshot: $pricesSnapshot, ')
          ..write('fees: $fees, ')
          ..write('isWhatsAppSent: $isWhatsAppSent, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    contractId,
    scheduleId,
    paymentDate,
    amountPaid,
    meterPriceAtPayment,
    convertedMeters,
    pricesSnapshot,
    fees,
    isWhatsAppSent,
    userId,
    createdAt,
    updatedAt,
    isDeleted,
    isSynced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PaymentsLedgerData &&
          other.id == this.id &&
          other.contractId == this.contractId &&
          other.scheduleId == this.scheduleId &&
          other.paymentDate == this.paymentDate &&
          other.amountPaid == this.amountPaid &&
          other.meterPriceAtPayment == this.meterPriceAtPayment &&
          other.convertedMeters == this.convertedMeters &&
          other.pricesSnapshot == this.pricesSnapshot &&
          other.fees == this.fees &&
          other.isWhatsAppSent == this.isWhatsAppSent &&
          other.userId == this.userId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.isSynced == this.isSynced);
}

class PaymentsLedgerCompanion extends UpdateCompanion<PaymentsLedgerData> {
  final Value<String> id;
  final Value<String> contractId;
  final Value<String?> scheduleId;
  final Value<DateTime> paymentDate;
  final Value<double> amountPaid;
  final Value<double> meterPriceAtPayment;
  final Value<double> convertedMeters;
  final Value<String> pricesSnapshot;
  final Value<double> fees;
  final Value<bool> isWhatsAppSent;
  final Value<String> userId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<bool> isSynced;
  final Value<int> rowid;
  const PaymentsLedgerCompanion({
    this.id = const Value.absent(),
    this.contractId = const Value.absent(),
    this.scheduleId = const Value.absent(),
    this.paymentDate = const Value.absent(),
    this.amountPaid = const Value.absent(),
    this.meterPriceAtPayment = const Value.absent(),
    this.convertedMeters = const Value.absent(),
    this.pricesSnapshot = const Value.absent(),
    this.fees = const Value.absent(),
    this.isWhatsAppSent = const Value.absent(),
    this.userId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PaymentsLedgerCompanion.insert({
    this.id = const Value.absent(),
    required String contractId,
    this.scheduleId = const Value.absent(),
    required DateTime paymentDate,
    required double amountPaid,
    required double meterPriceAtPayment,
    required double convertedMeters,
    this.pricesSnapshot = const Value.absent(),
    this.fees = const Value.absent(),
    this.isWhatsAppSent = const Value.absent(),
    required String userId,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : contractId = Value(contractId),
       paymentDate = Value(paymentDate),
       amountPaid = Value(amountPaid),
       meterPriceAtPayment = Value(meterPriceAtPayment),
       convertedMeters = Value(convertedMeters),
       userId = Value(userId);
  static Insertable<PaymentsLedgerData> custom({
    Expression<String>? id,
    Expression<String>? contractId,
    Expression<String>? scheduleId,
    Expression<DateTime>? paymentDate,
    Expression<double>? amountPaid,
    Expression<double>? meterPriceAtPayment,
    Expression<double>? convertedMeters,
    Expression<String>? pricesSnapshot,
    Expression<double>? fees,
    Expression<bool>? isWhatsAppSent,
    Expression<String>? userId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<bool>? isSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (contractId != null) 'contract_id': contractId,
      if (scheduleId != null) 'schedule_id': scheduleId,
      if (paymentDate != null) 'payment_date': paymentDate,
      if (amountPaid != null) 'amount_paid': amountPaid,
      if (meterPriceAtPayment != null)
        'meter_price_at_payment': meterPriceAtPayment,
      if (convertedMeters != null) 'converted_meters': convertedMeters,
      if (pricesSnapshot != null) 'prices_snapshot': pricesSnapshot,
      if (fees != null) 'fees': fees,
      if (isWhatsAppSent != null) 'is_whats_app_sent': isWhatsAppSent,
      if (userId != null) 'user_id': userId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isSynced != null) 'is_synced': isSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PaymentsLedgerCompanion copyWith({
    Value<String>? id,
    Value<String>? contractId,
    Value<String?>? scheduleId,
    Value<DateTime>? paymentDate,
    Value<double>? amountPaid,
    Value<double>? meterPriceAtPayment,
    Value<double>? convertedMeters,
    Value<String>? pricesSnapshot,
    Value<double>? fees,
    Value<bool>? isWhatsAppSent,
    Value<String>? userId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isDeleted,
    Value<bool>? isSynced,
    Value<int>? rowid,
  }) {
    return PaymentsLedgerCompanion(
      id: id ?? this.id,
      contractId: contractId ?? this.contractId,
      scheduleId: scheduleId ?? this.scheduleId,
      paymentDate: paymentDate ?? this.paymentDate,
      amountPaid: amountPaid ?? this.amountPaid,
      meterPriceAtPayment: meterPriceAtPayment ?? this.meterPriceAtPayment,
      convertedMeters: convertedMeters ?? this.convertedMeters,
      pricesSnapshot: pricesSnapshot ?? this.pricesSnapshot,
      fees: fees ?? this.fees,
      isWhatsAppSent: isWhatsAppSent ?? this.isWhatsAppSent,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      isSynced: isSynced ?? this.isSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (contractId.present) {
      map['contract_id'] = Variable<String>(contractId.value);
    }
    if (scheduleId.present) {
      map['schedule_id'] = Variable<String>(scheduleId.value);
    }
    if (paymentDate.present) {
      map['payment_date'] = Variable<DateTime>(paymentDate.value);
    }
    if (amountPaid.present) {
      map['amount_paid'] = Variable<double>(amountPaid.value);
    }
    if (meterPriceAtPayment.present) {
      map['meter_price_at_payment'] = Variable<double>(
        meterPriceAtPayment.value,
      );
    }
    if (convertedMeters.present) {
      map['converted_meters'] = Variable<double>(convertedMeters.value);
    }
    if (pricesSnapshot.present) {
      map['prices_snapshot'] = Variable<String>(pricesSnapshot.value);
    }
    if (fees.present) {
      map['fees'] = Variable<double>(fees.value);
    }
    if (isWhatsAppSent.present) {
      map['is_whats_app_sent'] = Variable<bool>(isWhatsAppSent.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentsLedgerCompanion(')
          ..write('id: $id, ')
          ..write('contractId: $contractId, ')
          ..write('scheduleId: $scheduleId, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('amountPaid: $amountPaid, ')
          ..write('meterPriceAtPayment: $meterPriceAtPayment, ')
          ..write('convertedMeters: $convertedMeters, ')
          ..write('pricesSnapshot: $pricesSnapshot, ')
          ..write('fees: $fees, ')
          ..write('isWhatsAppSent: $isWhatsAppSent, ')
          ..write('userId: $userId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isSynced: $isSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppRolesTable extends AppRoles with TableInfo<$AppRolesTable, AppRole> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppRolesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: () => _uuid.v7(),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _permissionsJsonMeta = const VerificationMeta(
    'permissionsJson',
  );
  @override
  late final GeneratedColumn<String> permissionsJson = GeneratedColumn<String>(
    'permissions_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _isSystemRoleMeta = const VerificationMeta(
    'isSystemRole',
  );
  @override
  late final GeneratedColumn<bool> isSystemRole = GeneratedColumn<bool>(
    'is_system_role',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_system_role" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    permissionsJson,
    isSystemRole,
    createdAt,
    updatedAt,
    isDeleted,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_roles';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppRole> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('permissions_json')) {
      context.handle(
        _permissionsJsonMeta,
        permissionsJson.isAcceptableOrUnknown(
          data['permissions_json']!,
          _permissionsJsonMeta,
        ),
      );
    }
    if (data.containsKey('is_system_role')) {
      context.handle(
        _isSystemRoleMeta,
        isSystemRole.isAcceptableOrUnknown(
          data['is_system_role']!,
          _isSystemRoleMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppRole map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppRole(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      permissionsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}permissions_json'],
      )!,
      isSystemRole: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_system_role'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  $AppRolesTable createAlias(String alias) {
    return $AppRolesTable(attachedDatabase, alias);
  }
}

class AppRole extends DataClass implements Insertable<AppRole> {
  final String id;
  final String name;
  final String permissionsJson;
  final bool isSystemRole;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final bool isSynced;
  const AppRole({
    required this.id,
    required this.name,
    required this.permissionsJson,
    required this.isSystemRole,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['permissions_json'] = Variable<String>(permissionsJson);
    map['is_system_role'] = Variable<bool>(isSystemRole);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  AppRolesCompanion toCompanion(bool nullToAbsent) {
    return AppRolesCompanion(
      id: Value(id),
      name: Value(name),
      permissionsJson: Value(permissionsJson),
      isSystemRole: Value(isSystemRole),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      isSynced: Value(isSynced),
    );
  }

  factory AppRole.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppRole(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      permissionsJson: serializer.fromJson<String>(json['permissionsJson']),
      isSystemRole: serializer.fromJson<bool>(json['isSystemRole']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'permissionsJson': serializer.toJson<String>(permissionsJson),
      'isSystemRole': serializer.toJson<bool>(isSystemRole),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  AppRole copyWith({
    String? id,
    String? name,
    String? permissionsJson,
    bool? isSystemRole,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    bool? isSynced,
  }) => AppRole(
    id: id ?? this.id,
    name: name ?? this.name,
    permissionsJson: permissionsJson ?? this.permissionsJson,
    isSystemRole: isSystemRole ?? this.isSystemRole,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
    isSynced: isSynced ?? this.isSynced,
  );
  AppRole copyWithCompanion(AppRolesCompanion data) {
    return AppRole(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      permissionsJson: data.permissionsJson.present
          ? data.permissionsJson.value
          : this.permissionsJson,
      isSystemRole: data.isSystemRole.present
          ? data.isSystemRole.value
          : this.isSystemRole,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppRole(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('permissionsJson: $permissionsJson, ')
          ..write('isSystemRole: $isSystemRole, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    permissionsJson,
    isSystemRole,
    createdAt,
    updatedAt,
    isDeleted,
    isSynced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppRole &&
          other.id == this.id &&
          other.name == this.name &&
          other.permissionsJson == this.permissionsJson &&
          other.isSystemRole == this.isSystemRole &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.isSynced == this.isSynced);
}

class AppRolesCompanion extends UpdateCompanion<AppRole> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> permissionsJson;
  final Value<bool> isSystemRole;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<bool> isSynced;
  final Value<int> rowid;
  const AppRolesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.permissionsJson = const Value.absent(),
    this.isSystemRole = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppRolesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.permissionsJson = const Value.absent(),
    this.isSystemRole = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : name = Value(name);
  static Insertable<AppRole> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? permissionsJson,
    Expression<bool>? isSystemRole,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<bool>? isSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (permissionsJson != null) 'permissions_json': permissionsJson,
      if (isSystemRole != null) 'is_system_role': isSystemRole,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isSynced != null) 'is_synced': isSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppRolesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? permissionsJson,
    Value<bool>? isSystemRole,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isDeleted,
    Value<bool>? isSynced,
    Value<int>? rowid,
  }) {
    return AppRolesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      permissionsJson: permissionsJson ?? this.permissionsJson,
      isSystemRole: isSystemRole ?? this.isSystemRole,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      isSynced: isSynced ?? this.isSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (permissionsJson.present) {
      map['permissions_json'] = Variable<String>(permissionsJson.value);
    }
    if (isSystemRole.present) {
      map['is_system_role'] = Variable<bool>(isSystemRole.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppRolesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('permissionsJson: $permissionsJson, ')
          ..write('isSystemRole: $isSystemRole, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isSynced: $isSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalUsersTable extends LocalUsers
    with TableInfo<$LocalUsersTable, LocalUser> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalUsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fullNameMeta = const VerificationMeta(
    'fullName',
  );
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
    'full_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleIdMeta = const VerificationMeta('roleId');
  @override
  late final GeneratedColumn<String> roleId = GeneratedColumn<String>(
    'role_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES app_roles (id)',
    ),
  );
  static const VerificationMeta _extraPermissionsJsonMeta =
      const VerificationMeta('extraPermissionsJson');
  @override
  late final GeneratedColumn<String> extraPermissionsJson =
      GeneratedColumn<String>(
        'extra_permissions_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _revokedPermissionsJsonMeta =
      const VerificationMeta('revokedPermissionsJson');
  @override
  late final GeneratedColumn<String> revokedPermissionsJson =
      GeneratedColumn<String>(
        'revoked_permissions_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: () => DateTime.now().toUtc(),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isSyncedMeta = const VerificationMeta(
    'isSynced',
  );
  @override
  late final GeneratedColumn<bool> isSynced = GeneratedColumn<bool>(
    'is_synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    fullName,
    email,
    roleId,
    extraPermissionsJson,
    revokedPermissionsJson,
    isActive,
    createdAt,
    updatedAt,
    isDeleted,
    isSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_users';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalUser> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('full_name')) {
      context.handle(
        _fullNameMeta,
        fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('role_id')) {
      context.handle(
        _roleIdMeta,
        roleId.isAcceptableOrUnknown(data['role_id']!, _roleIdMeta),
      );
    }
    if (data.containsKey('extra_permissions_json')) {
      context.handle(
        _extraPermissionsJsonMeta,
        extraPermissionsJson.isAcceptableOrUnknown(
          data['extra_permissions_json']!,
          _extraPermissionsJsonMeta,
        ),
      );
    }
    if (data.containsKey('revoked_permissions_json')) {
      context.handle(
        _revokedPermissionsJsonMeta,
        revokedPermissionsJson.isAcceptableOrUnknown(
          data['revoked_permissions_json']!,
          _revokedPermissionsJsonMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('is_synced')) {
      context.handle(
        _isSyncedMeta,
        isSynced.isAcceptableOrUnknown(data['is_synced']!, _isSyncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalUser map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalUser(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      fullName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_name'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      roleId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role_id'],
      ),
      extraPermissionsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extra_permissions_json'],
      )!,
      revokedPermissionsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}revoked_permissions_json'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      isSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_synced'],
      )!,
    );
  }

  @override
  $LocalUsersTable createAlias(String alias) {
    return $LocalUsersTable(attachedDatabase, alias);
  }
}

class LocalUser extends DataClass implements Insertable<LocalUser> {
  final String id;
  final String? fullName;
  final String email;
  final String? roleId;
  final String extraPermissionsJson;
  final String revokedPermissionsJson;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final bool isSynced;
  const LocalUser({
    required this.id,
    this.fullName,
    required this.email,
    this.roleId,
    required this.extraPermissionsJson,
    required this.revokedPermissionsJson,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.isSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || fullName != null) {
      map['full_name'] = Variable<String>(fullName);
    }
    map['email'] = Variable<String>(email);
    if (!nullToAbsent || roleId != null) {
      map['role_id'] = Variable<String>(roleId);
    }
    map['extra_permissions_json'] = Variable<String>(extraPermissionsJson);
    map['revoked_permissions_json'] = Variable<String>(revokedPermissionsJson);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['is_synced'] = Variable<bool>(isSynced);
    return map;
  }

  LocalUsersCompanion toCompanion(bool nullToAbsent) {
    return LocalUsersCompanion(
      id: Value(id),
      fullName: fullName == null && nullToAbsent
          ? const Value.absent()
          : Value(fullName),
      email: Value(email),
      roleId: roleId == null && nullToAbsent
          ? const Value.absent()
          : Value(roleId),
      extraPermissionsJson: Value(extraPermissionsJson),
      revokedPermissionsJson: Value(revokedPermissionsJson),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isDeleted: Value(isDeleted),
      isSynced: Value(isSynced),
    );
  }

  factory LocalUser.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalUser(
      id: serializer.fromJson<String>(json['id']),
      fullName: serializer.fromJson<String?>(json['fullName']),
      email: serializer.fromJson<String>(json['email']),
      roleId: serializer.fromJson<String?>(json['roleId']),
      extraPermissionsJson: serializer.fromJson<String>(
        json['extraPermissionsJson'],
      ),
      revokedPermissionsJson: serializer.fromJson<String>(
        json['revokedPermissionsJson'],
      ),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      isSynced: serializer.fromJson<bool>(json['isSynced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'fullName': serializer.toJson<String?>(fullName),
      'email': serializer.toJson<String>(email),
      'roleId': serializer.toJson<String?>(roleId),
      'extraPermissionsJson': serializer.toJson<String>(extraPermissionsJson),
      'revokedPermissionsJson': serializer.toJson<String>(
        revokedPermissionsJson,
      ),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'isSynced': serializer.toJson<bool>(isSynced),
    };
  }

  LocalUser copyWith({
    String? id,
    Value<String?> fullName = const Value.absent(),
    String? email,
    Value<String?> roleId = const Value.absent(),
    String? extraPermissionsJson,
    String? revokedPermissionsJson,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    bool? isSynced,
  }) => LocalUser(
    id: id ?? this.id,
    fullName: fullName.present ? fullName.value : this.fullName,
    email: email ?? this.email,
    roleId: roleId.present ? roleId.value : this.roleId,
    extraPermissionsJson: extraPermissionsJson ?? this.extraPermissionsJson,
    revokedPermissionsJson:
        revokedPermissionsJson ?? this.revokedPermissionsJson,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isDeleted: isDeleted ?? this.isDeleted,
    isSynced: isSynced ?? this.isSynced,
  );
  LocalUser copyWithCompanion(LocalUsersCompanion data) {
    return LocalUser(
      id: data.id.present ? data.id.value : this.id,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      email: data.email.present ? data.email.value : this.email,
      roleId: data.roleId.present ? data.roleId.value : this.roleId,
      extraPermissionsJson: data.extraPermissionsJson.present
          ? data.extraPermissionsJson.value
          : this.extraPermissionsJson,
      revokedPermissionsJson: data.revokedPermissionsJson.present
          ? data.revokedPermissionsJson.value
          : this.revokedPermissionsJson,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      isSynced: data.isSynced.present ? data.isSynced.value : this.isSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalUser(')
          ..write('id: $id, ')
          ..write('fullName: $fullName, ')
          ..write('email: $email, ')
          ..write('roleId: $roleId, ')
          ..write('extraPermissionsJson: $extraPermissionsJson, ')
          ..write('revokedPermissionsJson: $revokedPermissionsJson, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isSynced: $isSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    fullName,
    email,
    roleId,
    extraPermissionsJson,
    revokedPermissionsJson,
    isActive,
    createdAt,
    updatedAt,
    isDeleted,
    isSynced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalUser &&
          other.id == this.id &&
          other.fullName == this.fullName &&
          other.email == this.email &&
          other.roleId == this.roleId &&
          other.extraPermissionsJson == this.extraPermissionsJson &&
          other.revokedPermissionsJson == this.revokedPermissionsJson &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isDeleted == this.isDeleted &&
          other.isSynced == this.isSynced);
}

class LocalUsersCompanion extends UpdateCompanion<LocalUser> {
  final Value<String> id;
  final Value<String?> fullName;
  final Value<String> email;
  final Value<String?> roleId;
  final Value<String> extraPermissionsJson;
  final Value<String> revokedPermissionsJson;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isDeleted;
  final Value<bool> isSynced;
  final Value<int> rowid;
  const LocalUsersCompanion({
    this.id = const Value.absent(),
    this.fullName = const Value.absent(),
    this.email = const Value.absent(),
    this.roleId = const Value.absent(),
    this.extraPermissionsJson = const Value.absent(),
    this.revokedPermissionsJson = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalUsersCompanion.insert({
    required String id,
    this.fullName = const Value.absent(),
    required String email,
    this.roleId = const Value.absent(),
    this.extraPermissionsJson = const Value.absent(),
    this.revokedPermissionsJson = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.isSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       email = Value(email);
  static Insertable<LocalUser> custom({
    Expression<String>? id,
    Expression<String>? fullName,
    Expression<String>? email,
    Expression<String>? roleId,
    Expression<String>? extraPermissionsJson,
    Expression<String>? revokedPermissionsJson,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isDeleted,
    Expression<bool>? isSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fullName != null) 'full_name': fullName,
      if (email != null) 'email': email,
      if (roleId != null) 'role_id': roleId,
      if (extraPermissionsJson != null)
        'extra_permissions_json': extraPermissionsJson,
      if (revokedPermissionsJson != null)
        'revoked_permissions_json': revokedPermissionsJson,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (isSynced != null) 'is_synced': isSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalUsersCompanion copyWith({
    Value<String>? id,
    Value<String?>? fullName,
    Value<String>? email,
    Value<String?>? roleId,
    Value<String>? extraPermissionsJson,
    Value<String>? revokedPermissionsJson,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isDeleted,
    Value<bool>? isSynced,
    Value<int>? rowid,
  }) {
    return LocalUsersCompanion(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      roleId: roleId ?? this.roleId,
      extraPermissionsJson: extraPermissionsJson ?? this.extraPermissionsJson,
      revokedPermissionsJson:
          revokedPermissionsJson ?? this.revokedPermissionsJson,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      isSynced: isSynced ?? this.isSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (roleId.present) {
      map['role_id'] = Variable<String>(roleId.value);
    }
    if (extraPermissionsJson.present) {
      map['extra_permissions_json'] = Variable<String>(
        extraPermissionsJson.value,
      );
    }
    if (revokedPermissionsJson.present) {
      map['revoked_permissions_json'] = Variable<String>(
        revokedPermissionsJson.value,
      );
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (isSynced.present) {
      map['is_synced'] = Variable<bool>(isSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalUsersCompanion(')
          ..write('id: $id, ')
          ..write('fullName: $fullName, ')
          ..write('email: $email, ')
          ..write('roleId: $roleId, ')
          ..write('extraPermissionsJson: $extraPermissionsJson, ')
          ..write('revokedPermissionsJson: $revokedPermissionsJson, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('isSynced: $isSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ClientsTable clients = $ClientsTable(this);
  late final $BuildingsTable buildings = $BuildingsTable(this);
  late final $ApartmentsTable apartments = $ApartmentsTable(this);
  late final $ContractsTable contracts = $ContractsTable(this);
  late final $MaterialPricesHistoryTable materialPricesHistory =
      $MaterialPricesHistoryTable(this);
  late final $InstallmentsScheduleTable installmentsSchedule =
      $InstallmentsScheduleTable(this);
  late final $PaymentsLedgerTable paymentsLedger = $PaymentsLedgerTable(this);
  late final $AppRolesTable appRoles = $AppRolesTable(this);
  late final $LocalUsersTable localUsers = $LocalUsersTable(this);
  late final Index idxClientsSync = Index(
    'idx_clients_sync',
    'CREATE INDEX idx_clients_sync ON clients (is_deleted, updated_at)',
  );
  late final Index idxContractsSync = Index(
    'idx_contracts_sync',
    'CREATE INDEX idx_contracts_sync ON contracts (is_deleted, updated_at, client_id)',
  );
  late final Index idxBuildingsSync = Index(
    'idx_buildings_sync',
    'CREATE INDEX idx_buildings_sync ON buildings (is_deleted, updated_at)',
  );
  late final Index idxApartmentsSync = Index(
    'idx_apartments_sync',
    'CREATE INDEX idx_apartments_sync ON apartments (is_deleted, updated_at, building_id)',
  );
  late final Index idxPricesSync = Index(
    'idx_prices_sync',
    'CREATE INDEX idx_prices_sync ON material_prices_history (is_deleted, updated_at, effective_date)',
  );
  late final Index idxSchedulesSync = Index(
    'idx_schedules_sync',
    'CREATE INDEX idx_schedules_sync ON installments_schedule (is_deleted, updated_at, contract_id)',
  );
  late final Index idxPaymentsSync = Index(
    'idx_payments_sync',
    'CREATE INDEX idx_payments_sync ON payments_ledger (is_deleted, updated_at, contract_id)',
  );
  late final Index idxRolesSync = Index(
    'idx_roles_sync',
    'CREATE INDEX idx_roles_sync ON app_roles (is_deleted, updated_at)',
  );
  late final Index idxUsersSync = Index(
    'idx_users_sync',
    'CREATE INDEX idx_users_sync ON local_users (is_deleted, updated_at)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    clients,
    buildings,
    apartments,
    contracts,
    materialPricesHistory,
    installmentsSchedule,
    paymentsLedger,
    appRoles,
    localUsers,
    idxClientsSync,
    idxContractsSync,
    idxBuildingsSync,
    idxApartmentsSync,
    idxPricesSync,
    idxSchedulesSync,
    idxPaymentsSync,
    idxRolesSync,
    idxUsersSync,
  ];
}

typedef $$ClientsTableCreateCompanionBuilder =
    ClientsCompanion Function({
      Value<String> id,
      required String name,
      required String phone,
      Value<String?> nationalId,
      required String userId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<bool> isSynced,
      Value<int> rowid,
    });
typedef $$ClientsTableUpdateCompanionBuilder =
    ClientsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> phone,
      Value<String?> nationalId,
      Value<String> userId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<bool> isSynced,
      Value<int> rowid,
    });

final class $$ClientsTableReferences
    extends BaseReferences<_$AppDatabase, $ClientsTable, Client> {
  $$ClientsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ContractsTable, List<Contract>>
  _contractsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.contracts,
    aliasName: $_aliasNameGenerator(db.clients.id, db.contracts.clientId),
  );

  $$ContractsTableProcessedTableManager get contractsRefs {
    final manager = $$ContractsTableTableManager(
      $_db,
      $_db.contracts,
    ).filter((f) => f.clientId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_contractsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ClientsTableFilterComposer
    extends Composer<_$AppDatabase, $ClientsTable> {
  $$ClientsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nationalId => $composableBuilder(
    column: $table.nationalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> contractsRefs(
    Expression<bool> Function($$ContractsTableFilterComposer f) f,
  ) {
    final $$ContractsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.contracts,
      getReferencedColumn: (t) => t.clientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContractsTableFilterComposer(
            $db: $db,
            $table: $db.contracts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ClientsTableOrderingComposer
    extends Composer<_$AppDatabase, $ClientsTable> {
  $$ClientsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nationalId => $composableBuilder(
    column: $table.nationalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ClientsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClientsTable> {
  $$ClientsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get nationalId => $composableBuilder(
    column: $table.nationalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  Expression<T> contractsRefs<T extends Object>(
    Expression<T> Function($$ContractsTableAnnotationComposer a) f,
  ) {
    final $$ContractsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.contracts,
      getReferencedColumn: (t) => t.clientId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContractsTableAnnotationComposer(
            $db: $db,
            $table: $db.contracts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ClientsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ClientsTable,
          Client,
          $$ClientsTableFilterComposer,
          $$ClientsTableOrderingComposer,
          $$ClientsTableAnnotationComposer,
          $$ClientsTableCreateCompanionBuilder,
          $$ClientsTableUpdateCompanionBuilder,
          (Client, $$ClientsTableReferences),
          Client,
          PrefetchHooks Function({bool contractsRefs})
        > {
  $$ClientsTableTableManager(_$AppDatabase db, $ClientsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClientsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClientsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClientsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> phone = const Value.absent(),
                Value<String?> nationalId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClientsCompanion(
                id: id,
                name: name,
                phone: phone,
                nationalId: nationalId,
                userId: userId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                isSynced: isSynced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String name,
                required String phone,
                Value<String?> nationalId = const Value.absent(),
                required String userId,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClientsCompanion.insert(
                id: id,
                name: name,
                phone: phone,
                nationalId: nationalId,
                userId: userId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                isSynced: isSynced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ClientsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({contractsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (contractsRefs) db.contracts],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (contractsRefs)
                    await $_getPrefetchedData<Client, $ClientsTable, Contract>(
                      currentTable: table,
                      referencedTable: $$ClientsTableReferences
                          ._contractsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ClientsTableReferences(db, table, p0).contractsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.clientId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ClientsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ClientsTable,
      Client,
      $$ClientsTableFilterComposer,
      $$ClientsTableOrderingComposer,
      $$ClientsTableAnnotationComposer,
      $$ClientsTableCreateCompanionBuilder,
      $$ClientsTableUpdateCompanionBuilder,
      (Client, $$ClientsTableReferences),
      Client,
      PrefetchHooks Function({bool contractsRefs})
    >;
typedef $$BuildingsTableCreateCompanionBuilder =
    BuildingsCompanion Function({
      Value<String> id,
      required String name,
      Value<String?> location,
      Value<String> floorCoefficients,
      Value<String> directionCoefficients,
      Value<String> userId,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isSynced,
      Value<int> rowid,
    });
typedef $$BuildingsTableUpdateCompanionBuilder =
    BuildingsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> location,
      Value<String> floorCoefficients,
      Value<String> directionCoefficients,
      Value<String> userId,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isSynced,
      Value<int> rowid,
    });

final class $$BuildingsTableReferences
    extends BaseReferences<_$AppDatabase, $BuildingsTable, Building> {
  $$BuildingsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ApartmentsTable, List<Apartment>>
  _apartmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.apartments,
    aliasName: $_aliasNameGenerator(db.buildings.id, db.apartments.buildingId),
  );

  $$ApartmentsTableProcessedTableManager get apartmentsRefs {
    final manager = $$ApartmentsTableTableManager(
      $_db,
      $_db.apartments,
    ).filter((f) => f.buildingId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_apartmentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BuildingsTableFilterComposer
    extends Composer<_$AppDatabase, $BuildingsTable> {
  $$BuildingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get floorCoefficients => $composableBuilder(
    column: $table.floorCoefficients,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get directionCoefficients => $composableBuilder(
    column: $table.directionCoefficients,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> apartmentsRefs(
    Expression<bool> Function($$ApartmentsTableFilterComposer f) f,
  ) {
    final $$ApartmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.apartments,
      getReferencedColumn: (t) => t.buildingId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ApartmentsTableFilterComposer(
            $db: $db,
            $table: $db.apartments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BuildingsTableOrderingComposer
    extends Composer<_$AppDatabase, $BuildingsTable> {
  $$BuildingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get floorCoefficients => $composableBuilder(
    column: $table.floorCoefficients,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get directionCoefficients => $composableBuilder(
    column: $table.directionCoefficients,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BuildingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BuildingsTable> {
  $$BuildingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get floorCoefficients => $composableBuilder(
    column: $table.floorCoefficients,
    builder: (column) => column,
  );

  GeneratedColumn<String> get directionCoefficients => $composableBuilder(
    column: $table.directionCoefficients,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  Expression<T> apartmentsRefs<T extends Object>(
    Expression<T> Function($$ApartmentsTableAnnotationComposer a) f,
  ) {
    final $$ApartmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.apartments,
      getReferencedColumn: (t) => t.buildingId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ApartmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.apartments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BuildingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BuildingsTable,
          Building,
          $$BuildingsTableFilterComposer,
          $$BuildingsTableOrderingComposer,
          $$BuildingsTableAnnotationComposer,
          $$BuildingsTableCreateCompanionBuilder,
          $$BuildingsTableUpdateCompanionBuilder,
          (Building, $$BuildingsTableReferences),
          Building,
          PrefetchHooks Function({bool apartmentsRefs})
        > {
  $$BuildingsTableTableManager(_$AppDatabase db, $BuildingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BuildingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BuildingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BuildingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<String> floorCoefficients = const Value.absent(),
                Value<String> directionCoefficients = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BuildingsCompanion(
                id: id,
                name: name,
                location: location,
                floorCoefficients: floorCoefficients,
                directionCoefficients: directionCoefficients,
                userId: userId,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isSynced: isSynced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String name,
                Value<String?> location = const Value.absent(),
                Value<String> floorCoefficients = const Value.absent(),
                Value<String> directionCoefficients = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BuildingsCompanion.insert(
                id: id,
                name: name,
                location: location,
                floorCoefficients: floorCoefficients,
                directionCoefficients: directionCoefficients,
                userId: userId,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isSynced: isSynced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BuildingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({apartmentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (apartmentsRefs) db.apartments],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (apartmentsRefs)
                    await $_getPrefetchedData<
                      Building,
                      $BuildingsTable,
                      Apartment
                    >(
                      currentTable: table,
                      referencedTable: $$BuildingsTableReferences
                          ._apartmentsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$BuildingsTableReferences(
                            db,
                            table,
                            p0,
                          ).apartmentsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.buildingId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$BuildingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BuildingsTable,
      Building,
      $$BuildingsTableFilterComposer,
      $$BuildingsTableOrderingComposer,
      $$BuildingsTableAnnotationComposer,
      $$BuildingsTableCreateCompanionBuilder,
      $$BuildingsTableUpdateCompanionBuilder,
      (Building, $$BuildingsTableReferences),
      Building,
      PrefetchHooks Function({bool apartmentsRefs})
    >;
typedef $$ApartmentsTableCreateCompanionBuilder =
    ApartmentsCompanion Function({
      Value<String> id,
      required String buildingId,
      Value<String> unitType,
      required String apartmentNumber,
      required double area,
      required String floorName,
      required String directionName,
      Value<String> customCoefficients,
      Value<String> status,
      Value<String> userId,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isSynced,
      Value<int> rowid,
    });
typedef $$ApartmentsTableUpdateCompanionBuilder =
    ApartmentsCompanion Function({
      Value<String> id,
      Value<String> buildingId,
      Value<String> unitType,
      Value<String> apartmentNumber,
      Value<double> area,
      Value<String> floorName,
      Value<String> directionName,
      Value<String> customCoefficients,
      Value<String> status,
      Value<String> userId,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isSynced,
      Value<int> rowid,
    });

final class $$ApartmentsTableReferences
    extends BaseReferences<_$AppDatabase, $ApartmentsTable, Apartment> {
  $$ApartmentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BuildingsTable _buildingIdTable(_$AppDatabase db) =>
      db.buildings.createAlias(
        $_aliasNameGenerator(db.apartments.buildingId, db.buildings.id),
      );

  $$BuildingsTableProcessedTableManager get buildingId {
    final $_column = $_itemColumn<String>('building_id')!;

    final manager = $$BuildingsTableTableManager(
      $_db,
      $_db.buildings,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_buildingIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ContractsTable, List<Contract>>
  _contractsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.contracts,
    aliasName: $_aliasNameGenerator(db.apartments.id, db.contracts.apartmentId),
  );

  $$ContractsTableProcessedTableManager get contractsRefs {
    final manager = $$ContractsTableTableManager(
      $_db,
      $_db.contracts,
    ).filter((f) => f.apartmentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_contractsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ApartmentsTableFilterComposer
    extends Composer<_$AppDatabase, $ApartmentsTable> {
  $$ApartmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unitType => $composableBuilder(
    column: $table.unitType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get apartmentNumber => $composableBuilder(
    column: $table.apartmentNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get area => $composableBuilder(
    column: $table.area,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get floorName => $composableBuilder(
    column: $table.floorName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get directionName => $composableBuilder(
    column: $table.directionName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customCoefficients => $composableBuilder(
    column: $table.customCoefficients,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  $$BuildingsTableFilterComposer get buildingId {
    final $$BuildingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.buildingId,
      referencedTable: $db.buildings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BuildingsTableFilterComposer(
            $db: $db,
            $table: $db.buildings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> contractsRefs(
    Expression<bool> Function($$ContractsTableFilterComposer f) f,
  ) {
    final $$ContractsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.contracts,
      getReferencedColumn: (t) => t.apartmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContractsTableFilterComposer(
            $db: $db,
            $table: $db.contracts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ApartmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $ApartmentsTable> {
  $$ApartmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unitType => $composableBuilder(
    column: $table.unitType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get apartmentNumber => $composableBuilder(
    column: $table.apartmentNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get area => $composableBuilder(
    column: $table.area,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get floorName => $composableBuilder(
    column: $table.floorName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get directionName => $composableBuilder(
    column: $table.directionName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customCoefficients => $composableBuilder(
    column: $table.customCoefficients,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  $$BuildingsTableOrderingComposer get buildingId {
    final $$BuildingsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.buildingId,
      referencedTable: $db.buildings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BuildingsTableOrderingComposer(
            $db: $db,
            $table: $db.buildings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ApartmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ApartmentsTable> {
  $$ApartmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get unitType =>
      $composableBuilder(column: $table.unitType, builder: (column) => column);

  GeneratedColumn<String> get apartmentNumber => $composableBuilder(
    column: $table.apartmentNumber,
    builder: (column) => column,
  );

  GeneratedColumn<double> get area =>
      $composableBuilder(column: $table.area, builder: (column) => column);

  GeneratedColumn<String> get floorName =>
      $composableBuilder(column: $table.floorName, builder: (column) => column);

  GeneratedColumn<String> get directionName => $composableBuilder(
    column: $table.directionName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customCoefficients => $composableBuilder(
    column: $table.customCoefficients,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  $$BuildingsTableAnnotationComposer get buildingId {
    final $$BuildingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.buildingId,
      referencedTable: $db.buildings,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BuildingsTableAnnotationComposer(
            $db: $db,
            $table: $db.buildings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> contractsRefs<T extends Object>(
    Expression<T> Function($$ContractsTableAnnotationComposer a) f,
  ) {
    final $$ContractsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.contracts,
      getReferencedColumn: (t) => t.apartmentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContractsTableAnnotationComposer(
            $db: $db,
            $table: $db.contracts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ApartmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ApartmentsTable,
          Apartment,
          $$ApartmentsTableFilterComposer,
          $$ApartmentsTableOrderingComposer,
          $$ApartmentsTableAnnotationComposer,
          $$ApartmentsTableCreateCompanionBuilder,
          $$ApartmentsTableUpdateCompanionBuilder,
          (Apartment, $$ApartmentsTableReferences),
          Apartment,
          PrefetchHooks Function({bool buildingId, bool contractsRefs})
        > {
  $$ApartmentsTableTableManager(_$AppDatabase db, $ApartmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ApartmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ApartmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ApartmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> buildingId = const Value.absent(),
                Value<String> unitType = const Value.absent(),
                Value<String> apartmentNumber = const Value.absent(),
                Value<double> area = const Value.absent(),
                Value<String> floorName = const Value.absent(),
                Value<String> directionName = const Value.absent(),
                Value<String> customCoefficients = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ApartmentsCompanion(
                id: id,
                buildingId: buildingId,
                unitType: unitType,
                apartmentNumber: apartmentNumber,
                area: area,
                floorName: floorName,
                directionName: directionName,
                customCoefficients: customCoefficients,
                status: status,
                userId: userId,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isSynced: isSynced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String buildingId,
                Value<String> unitType = const Value.absent(),
                required String apartmentNumber,
                required double area,
                required String floorName,
                required String directionName,
                Value<String> customCoefficients = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ApartmentsCompanion.insert(
                id: id,
                buildingId: buildingId,
                unitType: unitType,
                apartmentNumber: apartmentNumber,
                area: area,
                floorName: floorName,
                directionName: directionName,
                customCoefficients: customCoefficients,
                status: status,
                userId: userId,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isSynced: isSynced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ApartmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({buildingId = false, contractsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (contractsRefs) db.contracts],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (buildingId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.buildingId,
                                referencedTable: $$ApartmentsTableReferences
                                    ._buildingIdTable(db),
                                referencedColumn: $$ApartmentsTableReferences
                                    ._buildingIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (contractsRefs)
                    await $_getPrefetchedData<
                      Apartment,
                      $ApartmentsTable,
                      Contract
                    >(
                      currentTable: table,
                      referencedTable: $$ApartmentsTableReferences
                          ._contractsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ApartmentsTableReferences(
                            db,
                            table,
                            p0,
                          ).contractsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.apartmentId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ApartmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ApartmentsTable,
      Apartment,
      $$ApartmentsTableFilterComposer,
      $$ApartmentsTableOrderingComposer,
      $$ApartmentsTableAnnotationComposer,
      $$ApartmentsTableCreateCompanionBuilder,
      $$ApartmentsTableUpdateCompanionBuilder,
      (Apartment, $$ApartmentsTableReferences),
      Apartment,
      PrefetchHooks Function({bool buildingId, bool contractsRefs})
    >;
typedef $$ContractsTableCreateCompanionBuilder =
    ContractsCompanion Function({
      Value<String> id,
      required String clientId,
      Value<String?> apartmentId,
      Value<String> apartmentDetails,
      Value<String> contractType,
      required double totalArea,
      required double baseMeterPriceAtSigning,
      Value<bool> isPenaltyActive,
      Value<double> penaltyPercentage,
      Value<int> penaltyIntervalMonths,
      Value<double> downPayment,
      Value<bool> isHandedOver,
      Value<DateTime?> agreedHandoverDate,
      Value<DateTime?> actualHandoverDate,
      Value<int> gracePeriodMonths,
      Value<String?> handoverNotes,
      Value<int> installmentsCount,
      Value<String> coefficients,
      required String guarantorName,
      Value<String?> contractFileUrl,
      Value<double> agreedMonthlyAmount,
      required String userId,
      required DateTime contractDate,
      Value<bool> isCompleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> lastActionDate,
      Value<String?> lastActionNote,
      Value<bool> isDeleted,
      Value<bool> isSynced,
      Value<int> rowid,
    });
typedef $$ContractsTableUpdateCompanionBuilder =
    ContractsCompanion Function({
      Value<String> id,
      Value<String> clientId,
      Value<String?> apartmentId,
      Value<String> apartmentDetails,
      Value<String> contractType,
      Value<double> totalArea,
      Value<double> baseMeterPriceAtSigning,
      Value<bool> isPenaltyActive,
      Value<double> penaltyPercentage,
      Value<int> penaltyIntervalMonths,
      Value<double> downPayment,
      Value<bool> isHandedOver,
      Value<DateTime?> agreedHandoverDate,
      Value<DateTime?> actualHandoverDate,
      Value<int> gracePeriodMonths,
      Value<String?> handoverNotes,
      Value<int> installmentsCount,
      Value<String> coefficients,
      Value<String> guarantorName,
      Value<String?> contractFileUrl,
      Value<double> agreedMonthlyAmount,
      Value<String> userId,
      Value<DateTime> contractDate,
      Value<bool> isCompleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> lastActionDate,
      Value<String?> lastActionNote,
      Value<bool> isDeleted,
      Value<bool> isSynced,
      Value<int> rowid,
    });

final class $$ContractsTableReferences
    extends BaseReferences<_$AppDatabase, $ContractsTable, Contract> {
  $$ContractsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ClientsTable _clientIdTable(_$AppDatabase db) => db.clients
      .createAlias($_aliasNameGenerator(db.contracts.clientId, db.clients.id));

  $$ClientsTableProcessedTableManager get clientId {
    final $_column = $_itemColumn<String>('client_id')!;

    final manager = $$ClientsTableTableManager(
      $_db,
      $_db.clients,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_clientIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ApartmentsTable _apartmentIdTable(_$AppDatabase db) =>
      db.apartments.createAlias(
        $_aliasNameGenerator(db.contracts.apartmentId, db.apartments.id),
      );

  $$ApartmentsTableProcessedTableManager? get apartmentId {
    final $_column = $_itemColumn<String>('apartment_id');
    if ($_column == null) return null;
    final manager = $$ApartmentsTableTableManager(
      $_db,
      $_db.apartments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_apartmentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $InstallmentsScheduleTable,
    List<InstallmentsScheduleData>
  >
  _installmentsScheduleRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.installmentsSchedule,
        aliasName: $_aliasNameGenerator(
          db.contracts.id,
          db.installmentsSchedule.contractId,
        ),
      );

  $$InstallmentsScheduleTableProcessedTableManager
  get installmentsScheduleRefs {
    final manager = $$InstallmentsScheduleTableTableManager(
      $_db,
      $_db.installmentsSchedule,
    ).filter((f) => f.contractId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _installmentsScheduleRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PaymentsLedgerTable, List<PaymentsLedgerData>>
  _paymentsLedgerRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.paymentsLedger,
    aliasName: $_aliasNameGenerator(
      db.contracts.id,
      db.paymentsLedger.contractId,
    ),
  );

  $$PaymentsLedgerTableProcessedTableManager get paymentsLedgerRefs {
    final manager = $$PaymentsLedgerTableTableManager(
      $_db,
      $_db.paymentsLedger,
    ).filter((f) => f.contractId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_paymentsLedgerRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ContractsTableFilterComposer
    extends Composer<_$AppDatabase, $ContractsTable> {
  $$ContractsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get apartmentDetails => $composableBuilder(
    column: $table.apartmentDetails,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contractType => $composableBuilder(
    column: $table.contractType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalArea => $composableBuilder(
    column: $table.totalArea,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get baseMeterPriceAtSigning => $composableBuilder(
    column: $table.baseMeterPriceAtSigning,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPenaltyActive => $composableBuilder(
    column: $table.isPenaltyActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get penaltyPercentage => $composableBuilder(
    column: $table.penaltyPercentage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get penaltyIntervalMonths => $composableBuilder(
    column: $table.penaltyIntervalMonths,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get downPayment => $composableBuilder(
    column: $table.downPayment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isHandedOver => $composableBuilder(
    column: $table.isHandedOver,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get agreedHandoverDate => $composableBuilder(
    column: $table.agreedHandoverDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get actualHandoverDate => $composableBuilder(
    column: $table.actualHandoverDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gracePeriodMonths => $composableBuilder(
    column: $table.gracePeriodMonths,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get handoverNotes => $composableBuilder(
    column: $table.handoverNotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get installmentsCount => $composableBuilder(
    column: $table.installmentsCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coefficients => $composableBuilder(
    column: $table.coefficients,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get guarantorName => $composableBuilder(
    column: $table.guarantorName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contractFileUrl => $composableBuilder(
    column: $table.contractFileUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get agreedMonthlyAmount => $composableBuilder(
    column: $table.agreedMonthlyAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get contractDate => $composableBuilder(
    column: $table.contractDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastActionDate => $composableBuilder(
    column: $table.lastActionDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastActionNote => $composableBuilder(
    column: $table.lastActionNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  $$ClientsTableFilterComposer get clientId {
    final $$ClientsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clientId,
      referencedTable: $db.clients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientsTableFilterComposer(
            $db: $db,
            $table: $db.clients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ApartmentsTableFilterComposer get apartmentId {
    final $$ApartmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.apartmentId,
      referencedTable: $db.apartments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ApartmentsTableFilterComposer(
            $db: $db,
            $table: $db.apartments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> installmentsScheduleRefs(
    Expression<bool> Function($$InstallmentsScheduleTableFilterComposer f) f,
  ) {
    final $$InstallmentsScheduleTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.installmentsSchedule,
      getReferencedColumn: (t) => t.contractId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InstallmentsScheduleTableFilterComposer(
            $db: $db,
            $table: $db.installmentsSchedule,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> paymentsLedgerRefs(
    Expression<bool> Function($$PaymentsLedgerTableFilterComposer f) f,
  ) {
    final $$PaymentsLedgerTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.paymentsLedger,
      getReferencedColumn: (t) => t.contractId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsLedgerTableFilterComposer(
            $db: $db,
            $table: $db.paymentsLedger,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ContractsTableOrderingComposer
    extends Composer<_$AppDatabase, $ContractsTable> {
  $$ContractsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get apartmentDetails => $composableBuilder(
    column: $table.apartmentDetails,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contractType => $composableBuilder(
    column: $table.contractType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalArea => $composableBuilder(
    column: $table.totalArea,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get baseMeterPriceAtSigning => $composableBuilder(
    column: $table.baseMeterPriceAtSigning,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPenaltyActive => $composableBuilder(
    column: $table.isPenaltyActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get penaltyPercentage => $composableBuilder(
    column: $table.penaltyPercentage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get penaltyIntervalMonths => $composableBuilder(
    column: $table.penaltyIntervalMonths,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get downPayment => $composableBuilder(
    column: $table.downPayment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isHandedOver => $composableBuilder(
    column: $table.isHandedOver,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get agreedHandoverDate => $composableBuilder(
    column: $table.agreedHandoverDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get actualHandoverDate => $composableBuilder(
    column: $table.actualHandoverDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gracePeriodMonths => $composableBuilder(
    column: $table.gracePeriodMonths,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get handoverNotes => $composableBuilder(
    column: $table.handoverNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get installmentsCount => $composableBuilder(
    column: $table.installmentsCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coefficients => $composableBuilder(
    column: $table.coefficients,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get guarantorName => $composableBuilder(
    column: $table.guarantorName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contractFileUrl => $composableBuilder(
    column: $table.contractFileUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get agreedMonthlyAmount => $composableBuilder(
    column: $table.agreedMonthlyAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get contractDate => $composableBuilder(
    column: $table.contractDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastActionDate => $composableBuilder(
    column: $table.lastActionDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastActionNote => $composableBuilder(
    column: $table.lastActionNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  $$ClientsTableOrderingComposer get clientId {
    final $$ClientsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clientId,
      referencedTable: $db.clients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientsTableOrderingComposer(
            $db: $db,
            $table: $db.clients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ApartmentsTableOrderingComposer get apartmentId {
    final $$ApartmentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.apartmentId,
      referencedTable: $db.apartments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ApartmentsTableOrderingComposer(
            $db: $db,
            $table: $db.apartments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ContractsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContractsTable> {
  $$ContractsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get apartmentDetails => $composableBuilder(
    column: $table.apartmentDetails,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contractType => $composableBuilder(
    column: $table.contractType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalArea =>
      $composableBuilder(column: $table.totalArea, builder: (column) => column);

  GeneratedColumn<double> get baseMeterPriceAtSigning => $composableBuilder(
    column: $table.baseMeterPriceAtSigning,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPenaltyActive => $composableBuilder(
    column: $table.isPenaltyActive,
    builder: (column) => column,
  );

  GeneratedColumn<double> get penaltyPercentage => $composableBuilder(
    column: $table.penaltyPercentage,
    builder: (column) => column,
  );

  GeneratedColumn<int> get penaltyIntervalMonths => $composableBuilder(
    column: $table.penaltyIntervalMonths,
    builder: (column) => column,
  );

  GeneratedColumn<double> get downPayment => $composableBuilder(
    column: $table.downPayment,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isHandedOver => $composableBuilder(
    column: $table.isHandedOver,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get agreedHandoverDate => $composableBuilder(
    column: $table.agreedHandoverDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get actualHandoverDate => $composableBuilder(
    column: $table.actualHandoverDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get gracePeriodMonths => $composableBuilder(
    column: $table.gracePeriodMonths,
    builder: (column) => column,
  );

  GeneratedColumn<String> get handoverNotes => $composableBuilder(
    column: $table.handoverNotes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get installmentsCount => $composableBuilder(
    column: $table.installmentsCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coefficients => $composableBuilder(
    column: $table.coefficients,
    builder: (column) => column,
  );

  GeneratedColumn<String> get guarantorName => $composableBuilder(
    column: $table.guarantorName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contractFileUrl => $composableBuilder(
    column: $table.contractFileUrl,
    builder: (column) => column,
  );

  GeneratedColumn<double> get agreedMonthlyAmount => $composableBuilder(
    column: $table.agreedMonthlyAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get contractDate => $composableBuilder(
    column: $table.contractDate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastActionDate => $composableBuilder(
    column: $table.lastActionDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastActionNote => $composableBuilder(
    column: $table.lastActionNote,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  $$ClientsTableAnnotationComposer get clientId {
    final $$ClientsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.clientId,
      referencedTable: $db.clients,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ClientsTableAnnotationComposer(
            $db: $db,
            $table: $db.clients,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ApartmentsTableAnnotationComposer get apartmentId {
    final $$ApartmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.apartmentId,
      referencedTable: $db.apartments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ApartmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.apartments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> installmentsScheduleRefs<T extends Object>(
    Expression<T> Function($$InstallmentsScheduleTableAnnotationComposer a) f,
  ) {
    final $$InstallmentsScheduleTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.installmentsSchedule,
          getReferencedColumn: (t) => t.contractId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$InstallmentsScheduleTableAnnotationComposer(
                $db: $db,
                $table: $db.installmentsSchedule,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> paymentsLedgerRefs<T extends Object>(
    Expression<T> Function($$PaymentsLedgerTableAnnotationComposer a) f,
  ) {
    final $$PaymentsLedgerTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.paymentsLedger,
      getReferencedColumn: (t) => t.contractId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsLedgerTableAnnotationComposer(
            $db: $db,
            $table: $db.paymentsLedger,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ContractsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ContractsTable,
          Contract,
          $$ContractsTableFilterComposer,
          $$ContractsTableOrderingComposer,
          $$ContractsTableAnnotationComposer,
          $$ContractsTableCreateCompanionBuilder,
          $$ContractsTableUpdateCompanionBuilder,
          (Contract, $$ContractsTableReferences),
          Contract,
          PrefetchHooks Function({
            bool clientId,
            bool apartmentId,
            bool installmentsScheduleRefs,
            bool paymentsLedgerRefs,
          })
        > {
  $$ContractsTableTableManager(_$AppDatabase db, $ContractsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContractsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContractsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContractsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> clientId = const Value.absent(),
                Value<String?> apartmentId = const Value.absent(),
                Value<String> apartmentDetails = const Value.absent(),
                Value<String> contractType = const Value.absent(),
                Value<double> totalArea = const Value.absent(),
                Value<double> baseMeterPriceAtSigning = const Value.absent(),
                Value<bool> isPenaltyActive = const Value.absent(),
                Value<double> penaltyPercentage = const Value.absent(),
                Value<int> penaltyIntervalMonths = const Value.absent(),
                Value<double> downPayment = const Value.absent(),
                Value<bool> isHandedOver = const Value.absent(),
                Value<DateTime?> agreedHandoverDate = const Value.absent(),
                Value<DateTime?> actualHandoverDate = const Value.absent(),
                Value<int> gracePeriodMonths = const Value.absent(),
                Value<String?> handoverNotes = const Value.absent(),
                Value<int> installmentsCount = const Value.absent(),
                Value<String> coefficients = const Value.absent(),
                Value<String> guarantorName = const Value.absent(),
                Value<String?> contractFileUrl = const Value.absent(),
                Value<double> agreedMonthlyAmount = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<DateTime> contractDate = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> lastActionDate = const Value.absent(),
                Value<String?> lastActionNote = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContractsCompanion(
                id: id,
                clientId: clientId,
                apartmentId: apartmentId,
                apartmentDetails: apartmentDetails,
                contractType: contractType,
                totalArea: totalArea,
                baseMeterPriceAtSigning: baseMeterPriceAtSigning,
                isPenaltyActive: isPenaltyActive,
                penaltyPercentage: penaltyPercentage,
                penaltyIntervalMonths: penaltyIntervalMonths,
                downPayment: downPayment,
                isHandedOver: isHandedOver,
                agreedHandoverDate: agreedHandoverDate,
                actualHandoverDate: actualHandoverDate,
                gracePeriodMonths: gracePeriodMonths,
                handoverNotes: handoverNotes,
                installmentsCount: installmentsCount,
                coefficients: coefficients,
                guarantorName: guarantorName,
                contractFileUrl: contractFileUrl,
                agreedMonthlyAmount: agreedMonthlyAmount,
                userId: userId,
                contractDate: contractDate,
                isCompleted: isCompleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastActionDate: lastActionDate,
                lastActionNote: lastActionNote,
                isDeleted: isDeleted,
                isSynced: isSynced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String clientId,
                Value<String?> apartmentId = const Value.absent(),
                Value<String> apartmentDetails = const Value.absent(),
                Value<String> contractType = const Value.absent(),
                required double totalArea,
                required double baseMeterPriceAtSigning,
                Value<bool> isPenaltyActive = const Value.absent(),
                Value<double> penaltyPercentage = const Value.absent(),
                Value<int> penaltyIntervalMonths = const Value.absent(),
                Value<double> downPayment = const Value.absent(),
                Value<bool> isHandedOver = const Value.absent(),
                Value<DateTime?> agreedHandoverDate = const Value.absent(),
                Value<DateTime?> actualHandoverDate = const Value.absent(),
                Value<int> gracePeriodMonths = const Value.absent(),
                Value<String?> handoverNotes = const Value.absent(),
                Value<int> installmentsCount = const Value.absent(),
                Value<String> coefficients = const Value.absent(),
                required String guarantorName,
                Value<String?> contractFileUrl = const Value.absent(),
                Value<double> agreedMonthlyAmount = const Value.absent(),
                required String userId,
                required DateTime contractDate,
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> lastActionDate = const Value.absent(),
                Value<String?> lastActionNote = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContractsCompanion.insert(
                id: id,
                clientId: clientId,
                apartmentId: apartmentId,
                apartmentDetails: apartmentDetails,
                contractType: contractType,
                totalArea: totalArea,
                baseMeterPriceAtSigning: baseMeterPriceAtSigning,
                isPenaltyActive: isPenaltyActive,
                penaltyPercentage: penaltyPercentage,
                penaltyIntervalMonths: penaltyIntervalMonths,
                downPayment: downPayment,
                isHandedOver: isHandedOver,
                agreedHandoverDate: agreedHandoverDate,
                actualHandoverDate: actualHandoverDate,
                gracePeriodMonths: gracePeriodMonths,
                handoverNotes: handoverNotes,
                installmentsCount: installmentsCount,
                coefficients: coefficients,
                guarantorName: guarantorName,
                contractFileUrl: contractFileUrl,
                agreedMonthlyAmount: agreedMonthlyAmount,
                userId: userId,
                contractDate: contractDate,
                isCompleted: isCompleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastActionDate: lastActionDate,
                lastActionNote: lastActionNote,
                isDeleted: isDeleted,
                isSynced: isSynced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ContractsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                clientId = false,
                apartmentId = false,
                installmentsScheduleRefs = false,
                paymentsLedgerRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (installmentsScheduleRefs) db.installmentsSchedule,
                    if (paymentsLedgerRefs) db.paymentsLedger,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (clientId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.clientId,
                                    referencedTable: $$ContractsTableReferences
                                        ._clientIdTable(db),
                                    referencedColumn: $$ContractsTableReferences
                                        ._clientIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (apartmentId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.apartmentId,
                                    referencedTable: $$ContractsTableReferences
                                        ._apartmentIdTable(db),
                                    referencedColumn: $$ContractsTableReferences
                                        ._apartmentIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (installmentsScheduleRefs)
                        await $_getPrefetchedData<
                          Contract,
                          $ContractsTable,
                          InstallmentsScheduleData
                        >(
                          currentTable: table,
                          referencedTable: $$ContractsTableReferences
                              ._installmentsScheduleRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ContractsTableReferences(
                                db,
                                table,
                                p0,
                              ).installmentsScheduleRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.contractId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (paymentsLedgerRefs)
                        await $_getPrefetchedData<
                          Contract,
                          $ContractsTable,
                          PaymentsLedgerData
                        >(
                          currentTable: table,
                          referencedTable: $$ContractsTableReferences
                              ._paymentsLedgerRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ContractsTableReferences(
                                db,
                                table,
                                p0,
                              ).paymentsLedgerRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.contractId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ContractsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ContractsTable,
      Contract,
      $$ContractsTableFilterComposer,
      $$ContractsTableOrderingComposer,
      $$ContractsTableAnnotationComposer,
      $$ContractsTableCreateCompanionBuilder,
      $$ContractsTableUpdateCompanionBuilder,
      (Contract, $$ContractsTableReferences),
      Contract,
      PrefetchHooks Function({
        bool clientId,
        bool apartmentId,
        bool installmentsScheduleRefs,
        bool paymentsLedgerRefs,
      })
    >;
typedef $$MaterialPricesHistoryTableCreateCompanionBuilder =
    MaterialPricesHistoryCompanion Function({
      Value<String> id,
      Value<DateTime> effectiveDate,
      required double ironPrice,
      required double cementPrice,
      required double block15Price,
      required double formworkAndPouringWages,
      required double aggregateMaterialsPrice,
      required double ordinaryWorkerWage,
      required String userId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<bool> isSynced,
      Value<int> rowid,
    });
typedef $$MaterialPricesHistoryTableUpdateCompanionBuilder =
    MaterialPricesHistoryCompanion Function({
      Value<String> id,
      Value<DateTime> effectiveDate,
      Value<double> ironPrice,
      Value<double> cementPrice,
      Value<double> block15Price,
      Value<double> formworkAndPouringWages,
      Value<double> aggregateMaterialsPrice,
      Value<double> ordinaryWorkerWage,
      Value<String> userId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<bool> isSynced,
      Value<int> rowid,
    });

class $$MaterialPricesHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $MaterialPricesHistoryTable> {
  $$MaterialPricesHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get effectiveDate => $composableBuilder(
    column: $table.effectiveDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ironPrice => $composableBuilder(
    column: $table.ironPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cementPrice => $composableBuilder(
    column: $table.cementPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get block15Price => $composableBuilder(
    column: $table.block15Price,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get formworkAndPouringWages => $composableBuilder(
    column: $table.formworkAndPouringWages,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get aggregateMaterialsPrice => $composableBuilder(
    column: $table.aggregateMaterialsPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get ordinaryWorkerWage => $composableBuilder(
    column: $table.ordinaryWorkerWage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MaterialPricesHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $MaterialPricesHistoryTable> {
  $$MaterialPricesHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get effectiveDate => $composableBuilder(
    column: $table.effectiveDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ironPrice => $composableBuilder(
    column: $table.ironPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cementPrice => $composableBuilder(
    column: $table.cementPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get block15Price => $composableBuilder(
    column: $table.block15Price,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get formworkAndPouringWages => $composableBuilder(
    column: $table.formworkAndPouringWages,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get aggregateMaterialsPrice => $composableBuilder(
    column: $table.aggregateMaterialsPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get ordinaryWorkerWage => $composableBuilder(
    column: $table.ordinaryWorkerWage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MaterialPricesHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $MaterialPricesHistoryTable> {
  $$MaterialPricesHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get effectiveDate => $composableBuilder(
    column: $table.effectiveDate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get ironPrice =>
      $composableBuilder(column: $table.ironPrice, builder: (column) => column);

  GeneratedColumn<double> get cementPrice => $composableBuilder(
    column: $table.cementPrice,
    builder: (column) => column,
  );

  GeneratedColumn<double> get block15Price => $composableBuilder(
    column: $table.block15Price,
    builder: (column) => column,
  );

  GeneratedColumn<double> get formworkAndPouringWages => $composableBuilder(
    column: $table.formworkAndPouringWages,
    builder: (column) => column,
  );

  GeneratedColumn<double> get aggregateMaterialsPrice => $composableBuilder(
    column: $table.aggregateMaterialsPrice,
    builder: (column) => column,
  );

  GeneratedColumn<double> get ordinaryWorkerWage => $composableBuilder(
    column: $table.ordinaryWorkerWage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);
}

class $$MaterialPricesHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MaterialPricesHistoryTable,
          MaterialPricesHistoryData,
          $$MaterialPricesHistoryTableFilterComposer,
          $$MaterialPricesHistoryTableOrderingComposer,
          $$MaterialPricesHistoryTableAnnotationComposer,
          $$MaterialPricesHistoryTableCreateCompanionBuilder,
          $$MaterialPricesHistoryTableUpdateCompanionBuilder,
          (
            MaterialPricesHistoryData,
            BaseReferences<
              _$AppDatabase,
              $MaterialPricesHistoryTable,
              MaterialPricesHistoryData
            >,
          ),
          MaterialPricesHistoryData,
          PrefetchHooks Function()
        > {
  $$MaterialPricesHistoryTableTableManager(
    _$AppDatabase db,
    $MaterialPricesHistoryTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MaterialPricesHistoryTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$MaterialPricesHistoryTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MaterialPricesHistoryTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> effectiveDate = const Value.absent(),
                Value<double> ironPrice = const Value.absent(),
                Value<double> cementPrice = const Value.absent(),
                Value<double> block15Price = const Value.absent(),
                Value<double> formworkAndPouringWages = const Value.absent(),
                Value<double> aggregateMaterialsPrice = const Value.absent(),
                Value<double> ordinaryWorkerWage = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MaterialPricesHistoryCompanion(
                id: id,
                effectiveDate: effectiveDate,
                ironPrice: ironPrice,
                cementPrice: cementPrice,
                block15Price: block15Price,
                formworkAndPouringWages: formworkAndPouringWages,
                aggregateMaterialsPrice: aggregateMaterialsPrice,
                ordinaryWorkerWage: ordinaryWorkerWage,
                userId: userId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                isSynced: isSynced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> effectiveDate = const Value.absent(),
                required double ironPrice,
                required double cementPrice,
                required double block15Price,
                required double formworkAndPouringWages,
                required double aggregateMaterialsPrice,
                required double ordinaryWorkerWage,
                required String userId,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MaterialPricesHistoryCompanion.insert(
                id: id,
                effectiveDate: effectiveDate,
                ironPrice: ironPrice,
                cementPrice: cementPrice,
                block15Price: block15Price,
                formworkAndPouringWages: formworkAndPouringWages,
                aggregateMaterialsPrice: aggregateMaterialsPrice,
                ordinaryWorkerWage: ordinaryWorkerWage,
                userId: userId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                isSynced: isSynced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MaterialPricesHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MaterialPricesHistoryTable,
      MaterialPricesHistoryData,
      $$MaterialPricesHistoryTableFilterComposer,
      $$MaterialPricesHistoryTableOrderingComposer,
      $$MaterialPricesHistoryTableAnnotationComposer,
      $$MaterialPricesHistoryTableCreateCompanionBuilder,
      $$MaterialPricesHistoryTableUpdateCompanionBuilder,
      (
        MaterialPricesHistoryData,
        BaseReferences<
          _$AppDatabase,
          $MaterialPricesHistoryTable,
          MaterialPricesHistoryData
        >,
      ),
      MaterialPricesHistoryData,
      PrefetchHooks Function()
    >;
typedef $$InstallmentsScheduleTableCreateCompanionBuilder =
    InstallmentsScheduleCompanion Function({
      Value<String> id,
      required String contractId,
      required int installmentNumber,
      required DateTime dueDate,
      Value<String> status,
      Value<String?> notes,
      required String userId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<bool> isSynced,
      Value<int> rowid,
    });
typedef $$InstallmentsScheduleTableUpdateCompanionBuilder =
    InstallmentsScheduleCompanion Function({
      Value<String> id,
      Value<String> contractId,
      Value<int> installmentNumber,
      Value<DateTime> dueDate,
      Value<String> status,
      Value<String?> notes,
      Value<String> userId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<bool> isSynced,
      Value<int> rowid,
    });

final class $$InstallmentsScheduleTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $InstallmentsScheduleTable,
          InstallmentsScheduleData
        > {
  $$InstallmentsScheduleTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ContractsTable _contractIdTable(_$AppDatabase db) =>
      db.contracts.createAlias(
        $_aliasNameGenerator(
          db.installmentsSchedule.contractId,
          db.contracts.id,
        ),
      );

  $$ContractsTableProcessedTableManager get contractId {
    final $_column = $_itemColumn<String>('contract_id')!;

    final manager = $$ContractsTableTableManager(
      $_db,
      $_db.contracts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_contractIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PaymentsLedgerTable, List<PaymentsLedgerData>>
  _paymentsLedgerRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.paymentsLedger,
    aliasName: $_aliasNameGenerator(
      db.installmentsSchedule.id,
      db.paymentsLedger.scheduleId,
    ),
  );

  $$PaymentsLedgerTableProcessedTableManager get paymentsLedgerRefs {
    final manager = $$PaymentsLedgerTableTableManager(
      $_db,
      $_db.paymentsLedger,
    ).filter((f) => f.scheduleId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_paymentsLedgerRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$InstallmentsScheduleTableFilterComposer
    extends Composer<_$AppDatabase, $InstallmentsScheduleTable> {
  $$InstallmentsScheduleTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get installmentNumber => $composableBuilder(
    column: $table.installmentNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  $$ContractsTableFilterComposer get contractId {
    final $$ContractsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contractId,
      referencedTable: $db.contracts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContractsTableFilterComposer(
            $db: $db,
            $table: $db.contracts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> paymentsLedgerRefs(
    Expression<bool> Function($$PaymentsLedgerTableFilterComposer f) f,
  ) {
    final $$PaymentsLedgerTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.paymentsLedger,
      getReferencedColumn: (t) => t.scheduleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsLedgerTableFilterComposer(
            $db: $db,
            $table: $db.paymentsLedger,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$InstallmentsScheduleTableOrderingComposer
    extends Composer<_$AppDatabase, $InstallmentsScheduleTable> {
  $$InstallmentsScheduleTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get installmentNumber => $composableBuilder(
    column: $table.installmentNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  $$ContractsTableOrderingComposer get contractId {
    final $$ContractsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contractId,
      referencedTable: $db.contracts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContractsTableOrderingComposer(
            $db: $db,
            $table: $db.contracts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InstallmentsScheduleTableAnnotationComposer
    extends Composer<_$AppDatabase, $InstallmentsScheduleTable> {
  $$InstallmentsScheduleTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get installmentNumber => $composableBuilder(
    column: $table.installmentNumber,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  $$ContractsTableAnnotationComposer get contractId {
    final $$ContractsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contractId,
      referencedTable: $db.contracts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContractsTableAnnotationComposer(
            $db: $db,
            $table: $db.contracts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> paymentsLedgerRefs<T extends Object>(
    Expression<T> Function($$PaymentsLedgerTableAnnotationComposer a) f,
  ) {
    final $$PaymentsLedgerTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.paymentsLedger,
      getReferencedColumn: (t) => t.scheduleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PaymentsLedgerTableAnnotationComposer(
            $db: $db,
            $table: $db.paymentsLedger,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$InstallmentsScheduleTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InstallmentsScheduleTable,
          InstallmentsScheduleData,
          $$InstallmentsScheduleTableFilterComposer,
          $$InstallmentsScheduleTableOrderingComposer,
          $$InstallmentsScheduleTableAnnotationComposer,
          $$InstallmentsScheduleTableCreateCompanionBuilder,
          $$InstallmentsScheduleTableUpdateCompanionBuilder,
          (InstallmentsScheduleData, $$InstallmentsScheduleTableReferences),
          InstallmentsScheduleData,
          PrefetchHooks Function({bool contractId, bool paymentsLedgerRefs})
        > {
  $$InstallmentsScheduleTableTableManager(
    _$AppDatabase db,
    $InstallmentsScheduleTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InstallmentsScheduleTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InstallmentsScheduleTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$InstallmentsScheduleTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> contractId = const Value.absent(),
                Value<int> installmentNumber = const Value.absent(),
                Value<DateTime> dueDate = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InstallmentsScheduleCompanion(
                id: id,
                contractId: contractId,
                installmentNumber: installmentNumber,
                dueDate: dueDate,
                status: status,
                notes: notes,
                userId: userId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                isSynced: isSynced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String contractId,
                required int installmentNumber,
                required DateTime dueDate,
                Value<String> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required String userId,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InstallmentsScheduleCompanion.insert(
                id: id,
                contractId: contractId,
                installmentNumber: installmentNumber,
                dueDate: dueDate,
                status: status,
                notes: notes,
                userId: userId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                isSynced: isSynced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$InstallmentsScheduleTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({contractId = false, paymentsLedgerRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (paymentsLedgerRefs) db.paymentsLedger,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (contractId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.contractId,
                                    referencedTable:
                                        $$InstallmentsScheduleTableReferences
                                            ._contractIdTable(db),
                                    referencedColumn:
                                        $$InstallmentsScheduleTableReferences
                                            ._contractIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (paymentsLedgerRefs)
                        await $_getPrefetchedData<
                          InstallmentsScheduleData,
                          $InstallmentsScheduleTable,
                          PaymentsLedgerData
                        >(
                          currentTable: table,
                          referencedTable: $$InstallmentsScheduleTableReferences
                              ._paymentsLedgerRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$InstallmentsScheduleTableReferences(
                                db,
                                table,
                                p0,
                              ).paymentsLedgerRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.scheduleId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$InstallmentsScheduleTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InstallmentsScheduleTable,
      InstallmentsScheduleData,
      $$InstallmentsScheduleTableFilterComposer,
      $$InstallmentsScheduleTableOrderingComposer,
      $$InstallmentsScheduleTableAnnotationComposer,
      $$InstallmentsScheduleTableCreateCompanionBuilder,
      $$InstallmentsScheduleTableUpdateCompanionBuilder,
      (InstallmentsScheduleData, $$InstallmentsScheduleTableReferences),
      InstallmentsScheduleData,
      PrefetchHooks Function({bool contractId, bool paymentsLedgerRefs})
    >;
typedef $$PaymentsLedgerTableCreateCompanionBuilder =
    PaymentsLedgerCompanion Function({
      Value<String> id,
      required String contractId,
      Value<String?> scheduleId,
      required DateTime paymentDate,
      required double amountPaid,
      required double meterPriceAtPayment,
      required double convertedMeters,
      Value<String> pricesSnapshot,
      Value<double> fees,
      Value<bool> isWhatsAppSent,
      required String userId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<bool> isSynced,
      Value<int> rowid,
    });
typedef $$PaymentsLedgerTableUpdateCompanionBuilder =
    PaymentsLedgerCompanion Function({
      Value<String> id,
      Value<String> contractId,
      Value<String?> scheduleId,
      Value<DateTime> paymentDate,
      Value<double> amountPaid,
      Value<double> meterPriceAtPayment,
      Value<double> convertedMeters,
      Value<String> pricesSnapshot,
      Value<double> fees,
      Value<bool> isWhatsAppSent,
      Value<String> userId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<bool> isSynced,
      Value<int> rowid,
    });

final class $$PaymentsLedgerTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PaymentsLedgerTable,
          PaymentsLedgerData
        > {
  $$PaymentsLedgerTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ContractsTable _contractIdTable(_$AppDatabase db) =>
      db.contracts.createAlias(
        $_aliasNameGenerator(db.paymentsLedger.contractId, db.contracts.id),
      );

  $$ContractsTableProcessedTableManager get contractId {
    final $_column = $_itemColumn<String>('contract_id')!;

    final manager = $$ContractsTableTableManager(
      $_db,
      $_db.contracts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_contractIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $InstallmentsScheduleTable _scheduleIdTable(_$AppDatabase db) =>
      db.installmentsSchedule.createAlias(
        $_aliasNameGenerator(
          db.paymentsLedger.scheduleId,
          db.installmentsSchedule.id,
        ),
      );

  $$InstallmentsScheduleTableProcessedTableManager? get scheduleId {
    final $_column = $_itemColumn<String>('schedule_id');
    if ($_column == null) return null;
    final manager = $$InstallmentsScheduleTableTableManager(
      $_db,
      $_db.installmentsSchedule,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_scheduleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PaymentsLedgerTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentsLedgerTable> {
  $$PaymentsLedgerTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amountPaid => $composableBuilder(
    column: $table.amountPaid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get meterPriceAtPayment => $composableBuilder(
    column: $table.meterPriceAtPayment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get convertedMeters => $composableBuilder(
    column: $table.convertedMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pricesSnapshot => $composableBuilder(
    column: $table.pricesSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fees => $composableBuilder(
    column: $table.fees,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isWhatsAppSent => $composableBuilder(
    column: $table.isWhatsAppSent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  $$ContractsTableFilterComposer get contractId {
    final $$ContractsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contractId,
      referencedTable: $db.contracts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContractsTableFilterComposer(
            $db: $db,
            $table: $db.contracts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InstallmentsScheduleTableFilterComposer get scheduleId {
    final $$InstallmentsScheduleTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.scheduleId,
      referencedTable: $db.installmentsSchedule,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InstallmentsScheduleTableFilterComposer(
            $db: $db,
            $table: $db.installmentsSchedule,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PaymentsLedgerTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentsLedgerTable> {
  $$PaymentsLedgerTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amountPaid => $composableBuilder(
    column: $table.amountPaid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get meterPriceAtPayment => $composableBuilder(
    column: $table.meterPriceAtPayment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get convertedMeters => $composableBuilder(
    column: $table.convertedMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pricesSnapshot => $composableBuilder(
    column: $table.pricesSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fees => $composableBuilder(
    column: $table.fees,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isWhatsAppSent => $composableBuilder(
    column: $table.isWhatsAppSent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  $$ContractsTableOrderingComposer get contractId {
    final $$ContractsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contractId,
      referencedTable: $db.contracts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContractsTableOrderingComposer(
            $db: $db,
            $table: $db.contracts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InstallmentsScheduleTableOrderingComposer get scheduleId {
    final $$InstallmentsScheduleTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.scheduleId,
          referencedTable: $db.installmentsSchedule,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$InstallmentsScheduleTableOrderingComposer(
                $db: $db,
                $table: $db.installmentsSchedule,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$PaymentsLedgerTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentsLedgerTable> {
  $$PaymentsLedgerTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amountPaid => $composableBuilder(
    column: $table.amountPaid,
    builder: (column) => column,
  );

  GeneratedColumn<double> get meterPriceAtPayment => $composableBuilder(
    column: $table.meterPriceAtPayment,
    builder: (column) => column,
  );

  GeneratedColumn<double> get convertedMeters => $composableBuilder(
    column: $table.convertedMeters,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pricesSnapshot => $composableBuilder(
    column: $table.pricesSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fees =>
      $composableBuilder(column: $table.fees, builder: (column) => column);

  GeneratedColumn<bool> get isWhatsAppSent => $composableBuilder(
    column: $table.isWhatsAppSent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  $$ContractsTableAnnotationComposer get contractId {
    final $$ContractsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contractId,
      referencedTable: $db.contracts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContractsTableAnnotationComposer(
            $db: $db,
            $table: $db.contracts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InstallmentsScheduleTableAnnotationComposer get scheduleId {
    final $$InstallmentsScheduleTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.scheduleId,
          referencedTable: $db.installmentsSchedule,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$InstallmentsScheduleTableAnnotationComposer(
                $db: $db,
                $table: $db.installmentsSchedule,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$PaymentsLedgerTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PaymentsLedgerTable,
          PaymentsLedgerData,
          $$PaymentsLedgerTableFilterComposer,
          $$PaymentsLedgerTableOrderingComposer,
          $$PaymentsLedgerTableAnnotationComposer,
          $$PaymentsLedgerTableCreateCompanionBuilder,
          $$PaymentsLedgerTableUpdateCompanionBuilder,
          (PaymentsLedgerData, $$PaymentsLedgerTableReferences),
          PaymentsLedgerData,
          PrefetchHooks Function({bool contractId, bool scheduleId})
        > {
  $$PaymentsLedgerTableTableManager(
    _$AppDatabase db,
    $PaymentsLedgerTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentsLedgerTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentsLedgerTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentsLedgerTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> contractId = const Value.absent(),
                Value<String?> scheduleId = const Value.absent(),
                Value<DateTime> paymentDate = const Value.absent(),
                Value<double> amountPaid = const Value.absent(),
                Value<double> meterPriceAtPayment = const Value.absent(),
                Value<double> convertedMeters = const Value.absent(),
                Value<String> pricesSnapshot = const Value.absent(),
                Value<double> fees = const Value.absent(),
                Value<bool> isWhatsAppSent = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaymentsLedgerCompanion(
                id: id,
                contractId: contractId,
                scheduleId: scheduleId,
                paymentDate: paymentDate,
                amountPaid: amountPaid,
                meterPriceAtPayment: meterPriceAtPayment,
                convertedMeters: convertedMeters,
                pricesSnapshot: pricesSnapshot,
                fees: fees,
                isWhatsAppSent: isWhatsAppSent,
                userId: userId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                isSynced: isSynced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String contractId,
                Value<String?> scheduleId = const Value.absent(),
                required DateTime paymentDate,
                required double amountPaid,
                required double meterPriceAtPayment,
                required double convertedMeters,
                Value<String> pricesSnapshot = const Value.absent(),
                Value<double> fees = const Value.absent(),
                Value<bool> isWhatsAppSent = const Value.absent(),
                required String userId,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaymentsLedgerCompanion.insert(
                id: id,
                contractId: contractId,
                scheduleId: scheduleId,
                paymentDate: paymentDate,
                amountPaid: amountPaid,
                meterPriceAtPayment: meterPriceAtPayment,
                convertedMeters: convertedMeters,
                pricesSnapshot: pricesSnapshot,
                fees: fees,
                isWhatsAppSent: isWhatsAppSent,
                userId: userId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                isSynced: isSynced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PaymentsLedgerTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({contractId = false, scheduleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (contractId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.contractId,
                                referencedTable: $$PaymentsLedgerTableReferences
                                    ._contractIdTable(db),
                                referencedColumn:
                                    $$PaymentsLedgerTableReferences
                                        ._contractIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (scheduleId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.scheduleId,
                                referencedTable: $$PaymentsLedgerTableReferences
                                    ._scheduleIdTable(db),
                                referencedColumn:
                                    $$PaymentsLedgerTableReferences
                                        ._scheduleIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PaymentsLedgerTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PaymentsLedgerTable,
      PaymentsLedgerData,
      $$PaymentsLedgerTableFilterComposer,
      $$PaymentsLedgerTableOrderingComposer,
      $$PaymentsLedgerTableAnnotationComposer,
      $$PaymentsLedgerTableCreateCompanionBuilder,
      $$PaymentsLedgerTableUpdateCompanionBuilder,
      (PaymentsLedgerData, $$PaymentsLedgerTableReferences),
      PaymentsLedgerData,
      PrefetchHooks Function({bool contractId, bool scheduleId})
    >;
typedef $$AppRolesTableCreateCompanionBuilder =
    AppRolesCompanion Function({
      Value<String> id,
      required String name,
      Value<String> permissionsJson,
      Value<bool> isSystemRole,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<bool> isSynced,
      Value<int> rowid,
    });
typedef $$AppRolesTableUpdateCompanionBuilder =
    AppRolesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> permissionsJson,
      Value<bool> isSystemRole,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<bool> isSynced,
      Value<int> rowid,
    });

final class $$AppRolesTableReferences
    extends BaseReferences<_$AppDatabase, $AppRolesTable, AppRole> {
  $$AppRolesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$LocalUsersTable, List<LocalUser>>
  _localUsersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.localUsers,
    aliasName: $_aliasNameGenerator(db.appRoles.id, db.localUsers.roleId),
  );

  $$LocalUsersTableProcessedTableManager get localUsersRefs {
    final manager = $$LocalUsersTableTableManager(
      $_db,
      $_db.localUsers,
    ).filter((f) => f.roleId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_localUsersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AppRolesTableFilterComposer
    extends Composer<_$AppDatabase, $AppRolesTable> {
  $$AppRolesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get permissionsJson => $composableBuilder(
    column: $table.permissionsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSystemRole => $composableBuilder(
    column: $table.isSystemRole,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> localUsersRefs(
    Expression<bool> Function($$LocalUsersTableFilterComposer f) f,
  ) {
    final $$LocalUsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.localUsers,
      getReferencedColumn: (t) => t.roleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalUsersTableFilterComposer(
            $db: $db,
            $table: $db.localUsers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AppRolesTableOrderingComposer
    extends Composer<_$AppDatabase, $AppRolesTable> {
  $$AppRolesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get permissionsJson => $composableBuilder(
    column: $table.permissionsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSystemRole => $composableBuilder(
    column: $table.isSystemRole,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppRolesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppRolesTable> {
  $$AppRolesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get permissionsJson => $composableBuilder(
    column: $table.permissionsJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isSystemRole => $composableBuilder(
    column: $table.isSystemRole,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  Expression<T> localUsersRefs<T extends Object>(
    Expression<T> Function($$LocalUsersTableAnnotationComposer a) f,
  ) {
    final $$LocalUsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.localUsers,
      getReferencedColumn: (t) => t.roleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocalUsersTableAnnotationComposer(
            $db: $db,
            $table: $db.localUsers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AppRolesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppRolesTable,
          AppRole,
          $$AppRolesTableFilterComposer,
          $$AppRolesTableOrderingComposer,
          $$AppRolesTableAnnotationComposer,
          $$AppRolesTableCreateCompanionBuilder,
          $$AppRolesTableUpdateCompanionBuilder,
          (AppRole, $$AppRolesTableReferences),
          AppRole,
          PrefetchHooks Function({bool localUsersRefs})
        > {
  $$AppRolesTableTableManager(_$AppDatabase db, $AppRolesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppRolesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppRolesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppRolesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> permissionsJson = const Value.absent(),
                Value<bool> isSystemRole = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppRolesCompanion(
                id: id,
                name: name,
                permissionsJson: permissionsJson,
                isSystemRole: isSystemRole,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                isSynced: isSynced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required String name,
                Value<String> permissionsJson = const Value.absent(),
                Value<bool> isSystemRole = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppRolesCompanion.insert(
                id: id,
                name: name,
                permissionsJson: permissionsJson,
                isSystemRole: isSystemRole,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                isSynced: isSynced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AppRolesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({localUsersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (localUsersRefs) db.localUsers],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (localUsersRefs)
                    await $_getPrefetchedData<
                      AppRole,
                      $AppRolesTable,
                      LocalUser
                    >(
                      currentTable: table,
                      referencedTable: $$AppRolesTableReferences
                          ._localUsersRefsTable(db),
                      managerFromTypedResult: (p0) => $$AppRolesTableReferences(
                        db,
                        table,
                        p0,
                      ).localUsersRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.roleId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$AppRolesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppRolesTable,
      AppRole,
      $$AppRolesTableFilterComposer,
      $$AppRolesTableOrderingComposer,
      $$AppRolesTableAnnotationComposer,
      $$AppRolesTableCreateCompanionBuilder,
      $$AppRolesTableUpdateCompanionBuilder,
      (AppRole, $$AppRolesTableReferences),
      AppRole,
      PrefetchHooks Function({bool localUsersRefs})
    >;
typedef $$LocalUsersTableCreateCompanionBuilder =
    LocalUsersCompanion Function({
      required String id,
      Value<String?> fullName,
      required String email,
      Value<String?> roleId,
      Value<String> extraPermissionsJson,
      Value<String> revokedPermissionsJson,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<bool> isSynced,
      Value<int> rowid,
    });
typedef $$LocalUsersTableUpdateCompanionBuilder =
    LocalUsersCompanion Function({
      Value<String> id,
      Value<String?> fullName,
      Value<String> email,
      Value<String?> roleId,
      Value<String> extraPermissionsJson,
      Value<String> revokedPermissionsJson,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<bool> isDeleted,
      Value<bool> isSynced,
      Value<int> rowid,
    });

final class $$LocalUsersTableReferences
    extends BaseReferences<_$AppDatabase, $LocalUsersTable, LocalUser> {
  $$LocalUsersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AppRolesTable _roleIdTable(_$AppDatabase db) => db.appRoles
      .createAlias($_aliasNameGenerator(db.localUsers.roleId, db.appRoles.id));

  $$AppRolesTableProcessedTableManager? get roleId {
    final $_column = $_itemColumn<String>('role_id');
    if ($_column == null) return null;
    final manager = $$AppRolesTableTableManager(
      $_db,
      $_db.appRoles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_roleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LocalUsersTableFilterComposer
    extends Composer<_$AppDatabase, $LocalUsersTable> {
  $$LocalUsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extraPermissionsJson => $composableBuilder(
    column: $table.extraPermissionsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get revokedPermissionsJson => $composableBuilder(
    column: $table.revokedPermissionsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnFilters(column),
  );

  $$AppRolesTableFilterComposer get roleId {
    final $$AppRolesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roleId,
      referencedTable: $db.appRoles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppRolesTableFilterComposer(
            $db: $db,
            $table: $db.appRoles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LocalUsersTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalUsersTable> {
  $$LocalUsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extraPermissionsJson => $composableBuilder(
    column: $table.extraPermissionsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get revokedPermissionsJson => $composableBuilder(
    column: $table.revokedPermissionsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSynced => $composableBuilder(
    column: $table.isSynced,
    builder: (column) => ColumnOrderings(column),
  );

  $$AppRolesTableOrderingComposer get roleId {
    final $$AppRolesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roleId,
      referencedTable: $db.appRoles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppRolesTableOrderingComposer(
            $db: $db,
            $table: $db.appRoles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LocalUsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalUsersTable> {
  $$LocalUsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get extraPermissionsJson => $composableBuilder(
    column: $table.extraPermissionsJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get revokedPermissionsJson => $composableBuilder(
    column: $table.revokedPermissionsJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<bool> get isSynced =>
      $composableBuilder(column: $table.isSynced, builder: (column) => column);

  $$AppRolesTableAnnotationComposer get roleId {
    final $$AppRolesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.roleId,
      referencedTable: $db.appRoles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppRolesTableAnnotationComposer(
            $db: $db,
            $table: $db.appRoles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LocalUsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalUsersTable,
          LocalUser,
          $$LocalUsersTableFilterComposer,
          $$LocalUsersTableOrderingComposer,
          $$LocalUsersTableAnnotationComposer,
          $$LocalUsersTableCreateCompanionBuilder,
          $$LocalUsersTableUpdateCompanionBuilder,
          (LocalUser, $$LocalUsersTableReferences),
          LocalUser,
          PrefetchHooks Function({bool roleId})
        > {
  $$LocalUsersTableTableManager(_$AppDatabase db, $LocalUsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalUsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalUsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalUsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> fullName = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<String?> roleId = const Value.absent(),
                Value<String> extraPermissionsJson = const Value.absent(),
                Value<String> revokedPermissionsJson = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalUsersCompanion(
                id: id,
                fullName: fullName,
                email: email,
                roleId: roleId,
                extraPermissionsJson: extraPermissionsJson,
                revokedPermissionsJson: revokedPermissionsJson,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                isSynced: isSynced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> fullName = const Value.absent(),
                required String email,
                Value<String?> roleId = const Value.absent(),
                Value<String> extraPermissionsJson = const Value.absent(),
                Value<String> revokedPermissionsJson = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<bool> isSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalUsersCompanion.insert(
                id: id,
                fullName: fullName,
                email: email,
                roleId: roleId,
                extraPermissionsJson: extraPermissionsJson,
                revokedPermissionsJson: revokedPermissionsJson,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isDeleted: isDeleted,
                isSynced: isSynced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LocalUsersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({roleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (roleId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.roleId,
                                referencedTable: $$LocalUsersTableReferences
                                    ._roleIdTable(db),
                                referencedColumn: $$LocalUsersTableReferences
                                    ._roleIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$LocalUsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalUsersTable,
      LocalUser,
      $$LocalUsersTableFilterComposer,
      $$LocalUsersTableOrderingComposer,
      $$LocalUsersTableAnnotationComposer,
      $$LocalUsersTableCreateCompanionBuilder,
      $$LocalUsersTableUpdateCompanionBuilder,
      (LocalUser, $$LocalUsersTableReferences),
      LocalUser,
      PrefetchHooks Function({bool roleId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ClientsTableTableManager get clients =>
      $$ClientsTableTableManager(_db, _db.clients);
  $$BuildingsTableTableManager get buildings =>
      $$BuildingsTableTableManager(_db, _db.buildings);
  $$ApartmentsTableTableManager get apartments =>
      $$ApartmentsTableTableManager(_db, _db.apartments);
  $$ContractsTableTableManager get contracts =>
      $$ContractsTableTableManager(_db, _db.contracts);
  $$MaterialPricesHistoryTableTableManager get materialPricesHistory =>
      $$MaterialPricesHistoryTableTableManager(_db, _db.materialPricesHistory);
  $$InstallmentsScheduleTableTableManager get installmentsSchedule =>
      $$InstallmentsScheduleTableTableManager(_db, _db.installmentsSchedule);
  $$PaymentsLedgerTableTableManager get paymentsLedger =>
      $$PaymentsLedgerTableTableManager(_db, _db.paymentsLedger);
  $$AppRolesTableTableManager get appRoles =>
      $$AppRolesTableTableManager(_db, _db.appRoles);
  $$LocalUsersTableTableManager get localUsers =>
      $$LocalUsersTableTableManager(_db, _db.localUsers);
}
