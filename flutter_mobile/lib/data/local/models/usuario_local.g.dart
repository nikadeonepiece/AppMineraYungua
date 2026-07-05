// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'usuario_local.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetUsuarioLocalCollection on Isar {
  IsarCollection<UsuarioLocal> get usuarioLocals => this.collection();
}

const UsuarioLocalSchema = CollectionSchema(
  name: r'UsuarioLocal',
  id: -6273126276437217644,
  properties: {
    r'activo': PropertySchema(
      id: 0,
      name: r'activo',
      type: IsarType.bool,
    ),
    r'byRemoteId': PropertySchema(
      id: 1,
      name: r'byRemoteId',
      type: IsarType.long,
    ),
    r'empleadoId': PropertySchema(
      id: 2,
      name: r'empleadoId',
      type: IsarType.long,
    ),
    r'passwordHash': PropertySchema(
      id: 3,
      name: r'passwordHash',
      type: IsarType.string,
    ),
    r'remoteId': PropertySchema(
      id: 4,
      name: r'remoteId',
      type: IsarType.long,
    ),
    r'rolId': PropertySchema(
      id: 5,
      name: r'rolId',
      type: IsarType.long,
    ),
    r'syncedAt': PropertySchema(
      id: 6,
      name: r'syncedAt',
      type: IsarType.dateTime,
    ),
    r'updatedAt': PropertySchema(
      id: 7,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'username': PropertySchema(
      id: 8,
      name: r'username',
      type: IsarType.string,
    )
  },
  estimateSize: _usuarioLocalEstimateSize,
  serialize: _usuarioLocalSerialize,
  deserialize: _usuarioLocalDeserialize,
  deserializeProp: _usuarioLocalDeserializeProp,
  idName: r'id',
  indexes: {
    r'byRemoteId': IndexSchema(
      id: -4495488418248170120,
      name: r'byRemoteId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'byRemoteId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _usuarioLocalGetId,
  getLinks: _usuarioLocalGetLinks,
  attach: _usuarioLocalAttach,
  version: '3.1.0+1',
);

int _usuarioLocalEstimateSize(
  UsuarioLocal object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.passwordHash.length * 3;
  bytesCount += 3 + object.username.length * 3;
  return bytesCount;
}

void _usuarioLocalSerialize(
  UsuarioLocal object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.activo);
  writer.writeLong(offsets[1], object.byRemoteId);
  writer.writeLong(offsets[2], object.empleadoId);
  writer.writeString(offsets[3], object.passwordHash);
  writer.writeLong(offsets[4], object.remoteId);
  writer.writeLong(offsets[5], object.rolId);
  writer.writeDateTime(offsets[6], object.syncedAt);
  writer.writeDateTime(offsets[7], object.updatedAt);
  writer.writeString(offsets[8], object.username);
}

UsuarioLocal _usuarioLocalDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = UsuarioLocal();
  object.activo = reader.readBool(offsets[0]);
  object.empleadoId = reader.readLong(offsets[2]);
  object.id = id;
  object.passwordHash = reader.readString(offsets[3]);
  object.remoteId = reader.readLong(offsets[4]);
  object.rolId = reader.readLong(offsets[5]);
  object.syncedAt = reader.readDateTimeOrNull(offsets[6]);
  object.updatedAt = reader.readDateTime(offsets[7]);
  object.username = reader.readString(offsets[8]);
  return object;
}

P _usuarioLocalDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readLong(offset)) as P;
    case 6:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 7:
      return (reader.readDateTime(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _usuarioLocalGetId(UsuarioLocal object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _usuarioLocalGetLinks(UsuarioLocal object) {
  return [];
}

void _usuarioLocalAttach(
    IsarCollection<dynamic> col, Id id, UsuarioLocal object) {
  object.id = id;
}

extension UsuarioLocalByIndex on IsarCollection<UsuarioLocal> {
  Future<UsuarioLocal?> getByByRemoteId(int byRemoteId) {
    return getByIndex(r'byRemoteId', [byRemoteId]);
  }

  UsuarioLocal? getByByRemoteIdSync(int byRemoteId) {
    return getByIndexSync(r'byRemoteId', [byRemoteId]);
  }

  Future<bool> deleteByByRemoteId(int byRemoteId) {
    return deleteByIndex(r'byRemoteId', [byRemoteId]);
  }

  bool deleteByByRemoteIdSync(int byRemoteId) {
    return deleteByIndexSync(r'byRemoteId', [byRemoteId]);
  }

  Future<List<UsuarioLocal?>> getAllByByRemoteId(List<int> byRemoteIdValues) {
    final values = byRemoteIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'byRemoteId', values);
  }

  List<UsuarioLocal?> getAllByByRemoteIdSync(List<int> byRemoteIdValues) {
    final values = byRemoteIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'byRemoteId', values);
  }

  Future<int> deleteAllByByRemoteId(List<int> byRemoteIdValues) {
    final values = byRemoteIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'byRemoteId', values);
  }

  int deleteAllByByRemoteIdSync(List<int> byRemoteIdValues) {
    final values = byRemoteIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'byRemoteId', values);
  }

  Future<Id> putByByRemoteId(UsuarioLocal object) {
    return putByIndex(r'byRemoteId', object);
  }

  Id putByByRemoteIdSync(UsuarioLocal object, {bool saveLinks = true}) {
    return putByIndexSync(r'byRemoteId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByByRemoteId(List<UsuarioLocal> objects) {
    return putAllByIndex(r'byRemoteId', objects);
  }

  List<Id> putAllByByRemoteIdSync(List<UsuarioLocal> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'byRemoteId', objects, saveLinks: saveLinks);
  }
}

extension UsuarioLocalQueryWhereSort
    on QueryBuilder<UsuarioLocal, UsuarioLocal, QWhere> {
  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterWhere> anyByRemoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'byRemoteId'),
      );
    });
  }
}

extension UsuarioLocalQueryWhere
    on QueryBuilder<UsuarioLocal, UsuarioLocal, QWhereClause> {
  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterWhereClause> byRemoteIdEqualTo(
      int byRemoteId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'byRemoteId',
        value: [byRemoteId],
      ));
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterWhereClause>
      byRemoteIdNotEqualTo(int byRemoteId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'byRemoteId',
              lower: [],
              upper: [byRemoteId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'byRemoteId',
              lower: [byRemoteId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'byRemoteId',
              lower: [byRemoteId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'byRemoteId',
              lower: [],
              upper: [byRemoteId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterWhereClause>
      byRemoteIdGreaterThan(
    int byRemoteId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'byRemoteId',
        lower: [byRemoteId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterWhereClause>
      byRemoteIdLessThan(
    int byRemoteId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'byRemoteId',
        lower: [],
        upper: [byRemoteId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterWhereClause> byRemoteIdBetween(
    int lowerByRemoteId,
    int upperByRemoteId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'byRemoteId',
        lower: [lowerByRemoteId],
        includeLower: includeLower,
        upper: [upperByRemoteId],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension UsuarioLocalQueryFilter
    on QueryBuilder<UsuarioLocal, UsuarioLocal, QFilterCondition> {
  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterFilterCondition> activoEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activo',
        value: value,
      ));
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterFilterCondition>
      byRemoteIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'byRemoteId',
        value: value,
      ));
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterFilterCondition>
      byRemoteIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'byRemoteId',
        value: value,
      ));
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterFilterCondition>
      byRemoteIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'byRemoteId',
        value: value,
      ));
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterFilterCondition>
      byRemoteIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'byRemoteId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterFilterCondition>
      empleadoIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'empleadoId',
        value: value,
      ));
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterFilterCondition>
      empleadoIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'empleadoId',
        value: value,
      ));
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterFilterCondition>
      empleadoIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'empleadoId',
        value: value,
      ));
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterFilterCondition>
      empleadoIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'empleadoId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterFilterCondition>
      passwordHashEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'passwordHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterFilterCondition>
      passwordHashGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'passwordHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterFilterCondition>
      passwordHashLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'passwordHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterFilterCondition>
      passwordHashBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'passwordHash',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterFilterCondition>
      passwordHashStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'passwordHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterFilterCondition>
      passwordHashEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'passwordHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterFilterCondition>
      passwordHashContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'passwordHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterFilterCondition>
      passwordHashMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'passwordHash',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterFilterCondition>
      passwordHashIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'passwordHash',
        value: '',
      ));
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterFilterCondition>
      passwordHashIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'passwordHash',
        value: '',
      ));
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterFilterCondition>
      remoteIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'remoteId',
        value: value,
      ));
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterFilterCondition>
      remoteIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'remoteId',
        value: value,
      ));
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterFilterCondition>
      remoteIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'remoteId',
        value: value,
      ));
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterFilterCondition>
      remoteIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'remoteId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterFilterCondition> rolIdEqualTo(
      int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rolId',
        value: value,
      ));
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterFilterCondition>
      rolIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'rolId',
        value: value,
      ));
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterFilterCondition> rolIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'rolId',
        value: value,
      ));
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterFilterCondition> rolIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'rolId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterFilterCondition>
      syncedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'syncedAt',
      ));
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterFilterCondition>
      syncedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'syncedAt',
      ));
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterFilterCondition>
      syncedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterFilterCondition>
      syncedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'syncedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterFilterCondition>
      syncedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'syncedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterFilterCondition>
      syncedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'syncedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterFilterCondition>
      updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterFilterCondition>
      updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterFilterCondition>
      usernameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'username',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterFilterCondition>
      usernameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'username',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterFilterCondition>
      usernameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'username',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterFilterCondition>
      usernameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'username',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterFilterCondition>
      usernameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'username',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterFilterCondition>
      usernameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'username',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterFilterCondition>
      usernameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'username',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterFilterCondition>
      usernameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'username',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterFilterCondition>
      usernameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'username',
        value: '',
      ));
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterFilterCondition>
      usernameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'username',
        value: '',
      ));
    });
  }
}

extension UsuarioLocalQueryObject
    on QueryBuilder<UsuarioLocal, UsuarioLocal, QFilterCondition> {}

extension UsuarioLocalQueryLinks
    on QueryBuilder<UsuarioLocal, UsuarioLocal, QFilterCondition> {}

extension UsuarioLocalQuerySortBy
    on QueryBuilder<UsuarioLocal, UsuarioLocal, QSortBy> {
  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterSortBy> sortByActivo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activo', Sort.asc);
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterSortBy> sortByActivoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activo', Sort.desc);
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterSortBy> sortByByRemoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'byRemoteId', Sort.asc);
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterSortBy>
      sortByByRemoteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'byRemoteId', Sort.desc);
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterSortBy> sortByEmpleadoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'empleadoId', Sort.asc);
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterSortBy>
      sortByEmpleadoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'empleadoId', Sort.desc);
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterSortBy> sortByPasswordHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'passwordHash', Sort.asc);
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterSortBy>
      sortByPasswordHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'passwordHash', Sort.desc);
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterSortBy> sortByRemoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.asc);
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterSortBy> sortByRemoteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.desc);
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterSortBy> sortByRolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rolId', Sort.asc);
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterSortBy> sortByRolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rolId', Sort.desc);
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterSortBy> sortBySyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncedAt', Sort.asc);
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterSortBy> sortBySyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncedAt', Sort.desc);
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterSortBy> sortByUsername() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'username', Sort.asc);
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterSortBy> sortByUsernameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'username', Sort.desc);
    });
  }
}

extension UsuarioLocalQuerySortThenBy
    on QueryBuilder<UsuarioLocal, UsuarioLocal, QSortThenBy> {
  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterSortBy> thenByActivo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activo', Sort.asc);
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterSortBy> thenByActivoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activo', Sort.desc);
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterSortBy> thenByByRemoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'byRemoteId', Sort.asc);
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterSortBy>
      thenByByRemoteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'byRemoteId', Sort.desc);
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterSortBy> thenByEmpleadoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'empleadoId', Sort.asc);
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterSortBy>
      thenByEmpleadoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'empleadoId', Sort.desc);
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterSortBy> thenByPasswordHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'passwordHash', Sort.asc);
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterSortBy>
      thenByPasswordHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'passwordHash', Sort.desc);
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterSortBy> thenByRemoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.asc);
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterSortBy> thenByRemoteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.desc);
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterSortBy> thenByRolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rolId', Sort.asc);
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterSortBy> thenByRolIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rolId', Sort.desc);
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterSortBy> thenBySyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncedAt', Sort.asc);
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterSortBy> thenBySyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncedAt', Sort.desc);
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterSortBy> thenByUsername() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'username', Sort.asc);
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QAfterSortBy> thenByUsernameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'username', Sort.desc);
    });
  }
}

extension UsuarioLocalQueryWhereDistinct
    on QueryBuilder<UsuarioLocal, UsuarioLocal, QDistinct> {
  QueryBuilder<UsuarioLocal, UsuarioLocal, QDistinct> distinctByActivo() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'activo');
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QDistinct> distinctByByRemoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'byRemoteId');
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QDistinct> distinctByEmpleadoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'empleadoId');
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QDistinct> distinctByPasswordHash(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'passwordHash', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QDistinct> distinctByRemoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'remoteId');
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QDistinct> distinctByRolId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rolId');
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QDistinct> distinctBySyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncedAt');
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<UsuarioLocal, UsuarioLocal, QDistinct> distinctByUsername(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'username', caseSensitive: caseSensitive);
    });
  }
}

extension UsuarioLocalQueryProperty
    on QueryBuilder<UsuarioLocal, UsuarioLocal, QQueryProperty> {
  QueryBuilder<UsuarioLocal, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<UsuarioLocal, bool, QQueryOperations> activoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activo');
    });
  }

  QueryBuilder<UsuarioLocal, int, QQueryOperations> byRemoteIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'byRemoteId');
    });
  }

  QueryBuilder<UsuarioLocal, int, QQueryOperations> empleadoIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'empleadoId');
    });
  }

  QueryBuilder<UsuarioLocal, String, QQueryOperations> passwordHashProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'passwordHash');
    });
  }

  QueryBuilder<UsuarioLocal, int, QQueryOperations> remoteIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'remoteId');
    });
  }

  QueryBuilder<UsuarioLocal, int, QQueryOperations> rolIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rolId');
    });
  }

  QueryBuilder<UsuarioLocal, DateTime?, QQueryOperations> syncedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncedAt');
    });
  }

  QueryBuilder<UsuarioLocal, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<UsuarioLocal, String, QQueryOperations> usernameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'username');
    });
  }
}
