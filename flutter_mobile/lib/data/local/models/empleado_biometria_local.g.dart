// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'empleado_biometria_local.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetEmpleadoBiometriaLocalCollection on Isar {
  IsarCollection<EmpleadoBiometriaLocal> get empleadoBiometriaLocals =>
      this.collection();
}

const EmpleadoBiometriaLocalSchema = CollectionSchema(
  name: r'EmpleadoBiometriaLocal',
  id: -1142459529323450329,
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
    r'embedding': PropertySchema(
      id: 2,
      name: r'embedding',
      type: IsarType.doubleList,
    ),
    r'embeddingCipher': PropertySchema(
      id: 3,
      name: r'embeddingCipher',
      type: IsarType.longList,
    ),
    r'embeddingCipherVersion': PropertySchema(
      id: 4,
      name: r'embeddingCipherVersion',
      type: IsarType.long,
    ),
    r'embeddingDevice': PropertySchema(
      id: 5,
      name: r'embeddingDevice',
      type: IsarType.doubleList,
    ),
    r'embeddingDeviceCipher': PropertySchema(
      id: 6,
      name: r'embeddingDeviceCipher',
      type: IsarType.longList,
    ),
    r'embeddingDeviceCipherVersion': PropertySchema(
      id: 7,
      name: r'embeddingDeviceCipherVersion',
      type: IsarType.long,
    ),
    r'empleadoId': PropertySchema(
      id: 8,
      name: r'empleadoId',
      type: IsarType.long,
    ),
    r'remoteId': PropertySchema(
      id: 9,
      name: r'remoteId',
      type: IsarType.long,
    ),
    r'syncedAt': PropertySchema(
      id: 10,
      name: r'syncedAt',
      type: IsarType.dateTime,
    ),
    r'updatedAt': PropertySchema(
      id: 11,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _empleadoBiometriaLocalEstimateSize,
  serialize: _empleadoBiometriaLocalSerialize,
  deserialize: _empleadoBiometriaLocalDeserialize,
  deserializeProp: _empleadoBiometriaLocalDeserializeProp,
  idName: r'id',
  indexes: {
    r'empleadoId': IndexSchema(
      id: -8920847622704226999,
      name: r'empleadoId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'empleadoId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
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
  getId: _empleadoBiometriaLocalGetId,
  getLinks: _empleadoBiometriaLocalGetLinks,
  attach: _empleadoBiometriaLocalAttach,
  version: '3.1.0+1',
);

int _empleadoBiometriaLocalEstimateSize(
  EmpleadoBiometriaLocal object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.embeddingLegacy;
    if (value != null) {
      bytesCount += 3 + value.length * 8;
    }
  }
  {
    final value = object.embeddingCipher;
    if (value != null) {
      bytesCount += 3 + value.length * 8;
    }
  }
  {
    final value = object.embeddingDeviceLegacy;
    if (value != null) {
      bytesCount += 3 + value.length * 8;
    }
  }
  {
    final value = object.embeddingDeviceCipher;
    if (value != null) {
      bytesCount += 3 + value.length * 8;
    }
  }
  return bytesCount;
}

void _empleadoBiometriaLocalSerialize(
  EmpleadoBiometriaLocal object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.activo);
  writer.writeLong(offsets[1], object.byRemoteId);
  writer.writeDoubleList(offsets[2], object.embeddingLegacy);
  writer.writeLongList(offsets[3], object.embeddingCipher);
  writer.writeLong(offsets[4], object.embeddingCipherVersion);
  writer.writeDoubleList(offsets[5], object.embeddingDeviceLegacy);
  writer.writeLongList(offsets[6], object.embeddingDeviceCipher);
  writer.writeLong(offsets[7], object.embeddingDeviceCipherVersion);
  writer.writeLong(offsets[8], object.empleadoId);
  writer.writeLong(offsets[9], object.remoteId);
  writer.writeDateTime(offsets[10], object.syncedAt);
  writer.writeDateTime(offsets[11], object.updatedAt);
}

EmpleadoBiometriaLocal _empleadoBiometriaLocalDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = EmpleadoBiometriaLocal();
  object.activo = reader.readBool(offsets[0]);
  object.embeddingLegacy = reader.readDoubleList(offsets[2]);
  object.embeddingCipher = reader.readLongList(offsets[3]);
  object.embeddingCipherVersion = reader.readLong(offsets[4]);
  object.embeddingDeviceLegacy = reader.readDoubleList(offsets[5]);
  object.embeddingDeviceCipher = reader.readLongList(offsets[6]);
  object.embeddingDeviceCipherVersion = reader.readLong(offsets[7]);
  object.empleadoId = reader.readLong(offsets[8]);
  object.id = id;
  object.remoteId = reader.readLong(offsets[9]);
  object.syncedAt = reader.readDateTimeOrNull(offsets[10]);
  object.updatedAt = reader.readDateTime(offsets[11]);
  return object;
}

P _empleadoBiometriaLocalDeserializeProp<P>(
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
      return (reader.readDoubleList(offset)) as P;
    case 3:
      return (reader.readLongList(offset)) as P;
    case 4:
      return (reader.readLong(offset)) as P;
    case 5:
      return (reader.readDoubleList(offset)) as P;
    case 6:
      return (reader.readLongList(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 11:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _empleadoBiometriaLocalGetId(EmpleadoBiometriaLocal object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _empleadoBiometriaLocalGetLinks(
    EmpleadoBiometriaLocal object) {
  return [];
}

void _empleadoBiometriaLocalAttach(
    IsarCollection<dynamic> col, Id id, EmpleadoBiometriaLocal object) {
  object.id = id;
}

extension EmpleadoBiometriaLocalByIndex
    on IsarCollection<EmpleadoBiometriaLocal> {
  Future<EmpleadoBiometriaLocal?> getByByRemoteId(int byRemoteId) {
    return getByIndex(r'byRemoteId', [byRemoteId]);
  }

  EmpleadoBiometriaLocal? getByByRemoteIdSync(int byRemoteId) {
    return getByIndexSync(r'byRemoteId', [byRemoteId]);
  }

  Future<bool> deleteByByRemoteId(int byRemoteId) {
    return deleteByIndex(r'byRemoteId', [byRemoteId]);
  }

  bool deleteByByRemoteIdSync(int byRemoteId) {
    return deleteByIndexSync(r'byRemoteId', [byRemoteId]);
  }

  Future<List<EmpleadoBiometriaLocal?>> getAllByByRemoteId(
      List<int> byRemoteIdValues) {
    final values = byRemoteIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'byRemoteId', values);
  }

  List<EmpleadoBiometriaLocal?> getAllByByRemoteIdSync(
      List<int> byRemoteIdValues) {
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

  Future<Id> putByByRemoteId(EmpleadoBiometriaLocal object) {
    return putByIndex(r'byRemoteId', object);
  }

  Id putByByRemoteIdSync(EmpleadoBiometriaLocal object,
      {bool saveLinks = true}) {
    return putByIndexSync(r'byRemoteId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByByRemoteId(List<EmpleadoBiometriaLocal> objects) {
    return putAllByIndex(r'byRemoteId', objects);
  }

  List<Id> putAllByByRemoteIdSync(List<EmpleadoBiometriaLocal> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'byRemoteId', objects, saveLinks: saveLinks);
  }
}

extension EmpleadoBiometriaLocalQueryWhereSort
    on QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal, QWhere> {
  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal, QAfterWhere>
      anyEmpleadoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'empleadoId'),
      );
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal, QAfterWhere>
      anyByRemoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'byRemoteId'),
      );
    });
  }
}

extension EmpleadoBiometriaLocalQueryWhere on QueryBuilder<
    EmpleadoBiometriaLocal, EmpleadoBiometriaLocal, QWhereClause> {
  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterWhereClause> idBetween(
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

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterWhereClause> empleadoIdEqualTo(int empleadoId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'empleadoId',
        value: [empleadoId],
      ));
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterWhereClause> empleadoIdNotEqualTo(int empleadoId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'empleadoId',
              lower: [],
              upper: [empleadoId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'empleadoId',
              lower: [empleadoId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'empleadoId',
              lower: [empleadoId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'empleadoId',
              lower: [],
              upper: [empleadoId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterWhereClause> empleadoIdGreaterThan(
    int empleadoId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'empleadoId',
        lower: [empleadoId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterWhereClause> empleadoIdLessThan(
    int empleadoId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'empleadoId',
        lower: [],
        upper: [empleadoId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterWhereClause> empleadoIdBetween(
    int lowerEmpleadoId,
    int upperEmpleadoId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'empleadoId',
        lower: [lowerEmpleadoId],
        includeLower: includeLower,
        upper: [upperEmpleadoId],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterWhereClause> byRemoteIdEqualTo(int byRemoteId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'byRemoteId',
        value: [byRemoteId],
      ));
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterWhereClause> byRemoteIdNotEqualTo(int byRemoteId) {
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

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterWhereClause> byRemoteIdGreaterThan(
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

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterWhereClause> byRemoteIdLessThan(
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

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterWhereClause> byRemoteIdBetween(
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

extension EmpleadoBiometriaLocalQueryFilter on QueryBuilder<
    EmpleadoBiometriaLocal, EmpleadoBiometriaLocal, QFilterCondition> {
  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> activoEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activo',
        value: value,
      ));
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> byRemoteIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'byRemoteId',
        value: value,
      ));
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> byRemoteIdGreaterThan(
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

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> byRemoteIdLessThan(
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

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> byRemoteIdBetween(
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

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> embeddingLegacyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'embedding',
      ));
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> embeddingLegacyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'embedding',
      ));
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> embeddingLegacyElementEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'embedding',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> embeddingLegacyElementGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'embedding',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> embeddingLegacyElementLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'embedding',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> embeddingLegacyElementBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'embedding',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> embeddingLegacyLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'embedding',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> embeddingLegacyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'embedding',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> embeddingLegacyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'embedding',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> embeddingLegacyLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'embedding',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> embeddingLegacyLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'embedding',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> embeddingLegacyLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'embedding',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> embeddingCipherIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'embeddingCipher',
      ));
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> embeddingCipherIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'embeddingCipher',
      ));
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> embeddingCipherElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'embeddingCipher',
        value: value,
      ));
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> embeddingCipherElementGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'embeddingCipher',
        value: value,
      ));
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> embeddingCipherElementLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'embeddingCipher',
        value: value,
      ));
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> embeddingCipherElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'embeddingCipher',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> embeddingCipherLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'embeddingCipher',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> embeddingCipherIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'embeddingCipher',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> embeddingCipherIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'embeddingCipher',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> embeddingCipherLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'embeddingCipher',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> embeddingCipherLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'embeddingCipher',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> embeddingCipherLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'embeddingCipher',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> embeddingCipherVersionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'embeddingCipherVersion',
        value: value,
      ));
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> embeddingCipherVersionGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'embeddingCipherVersion',
        value: value,
      ));
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> embeddingCipherVersionLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'embeddingCipherVersion',
        value: value,
      ));
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> embeddingCipherVersionBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'embeddingCipherVersion',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> embeddingDeviceLegacyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'embeddingDevice',
      ));
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> embeddingDeviceLegacyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'embeddingDevice',
      ));
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> embeddingDeviceLegacyElementEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'embeddingDevice',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> embeddingDeviceLegacyElementGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'embeddingDevice',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> embeddingDeviceLegacyElementLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'embeddingDevice',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> embeddingDeviceLegacyElementBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'embeddingDevice',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> embeddingDeviceLegacyLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'embeddingDevice',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> embeddingDeviceLegacyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'embeddingDevice',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> embeddingDeviceLegacyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'embeddingDevice',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> embeddingDeviceLegacyLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'embeddingDevice',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> embeddingDeviceLegacyLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'embeddingDevice',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> embeddingDeviceLegacyLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'embeddingDevice',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> embeddingDeviceCipherIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'embeddingDeviceCipher',
      ));
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> embeddingDeviceCipherIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'embeddingDeviceCipher',
      ));
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> embeddingDeviceCipherElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'embeddingDeviceCipher',
        value: value,
      ));
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> embeddingDeviceCipherElementGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'embeddingDeviceCipher',
        value: value,
      ));
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> embeddingDeviceCipherElementLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'embeddingDeviceCipher',
        value: value,
      ));
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> embeddingDeviceCipherElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'embeddingDeviceCipher',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> embeddingDeviceCipherLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'embeddingDeviceCipher',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> embeddingDeviceCipherIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'embeddingDeviceCipher',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> embeddingDeviceCipherIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'embeddingDeviceCipher',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> embeddingDeviceCipherLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'embeddingDeviceCipher',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> embeddingDeviceCipherLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'embeddingDeviceCipher',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> embeddingDeviceCipherLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'embeddingDeviceCipher',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> embeddingDeviceCipherVersionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'embeddingDeviceCipherVersion',
        value: value,
      ));
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> embeddingDeviceCipherVersionGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'embeddingDeviceCipherVersion',
        value: value,
      ));
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> embeddingDeviceCipherVersionLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'embeddingDeviceCipherVersion',
        value: value,
      ));
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> embeddingDeviceCipherVersionBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'embeddingDeviceCipherVersion',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> empleadoIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'empleadoId',
        value: value,
      ));
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> empleadoIdGreaterThan(
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

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> empleadoIdLessThan(
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

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> empleadoIdBetween(
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

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> idLessThan(
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

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> idBetween(
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

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> remoteIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'remoteId',
        value: value,
      ));
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> remoteIdGreaterThan(
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

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> remoteIdLessThan(
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

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> remoteIdBetween(
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

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> syncedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'syncedAt',
      ));
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> syncedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'syncedAt',
      ));
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> syncedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> syncedAtGreaterThan(
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

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> syncedAtLessThan(
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

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> syncedAtBetween(
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

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> updatedAtGreaterThan(
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

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> updatedAtLessThan(
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

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal,
      QAfterFilterCondition> updatedAtBetween(
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
}

extension EmpleadoBiometriaLocalQueryObject on QueryBuilder<
    EmpleadoBiometriaLocal, EmpleadoBiometriaLocal, QFilterCondition> {}

extension EmpleadoBiometriaLocalQueryLinks on QueryBuilder<
    EmpleadoBiometriaLocal, EmpleadoBiometriaLocal, QFilterCondition> {}

extension EmpleadoBiometriaLocalQuerySortBy
    on QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal, QSortBy> {
  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal, QAfterSortBy>
      sortByActivo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activo', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal, QAfterSortBy>
      sortByActivoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activo', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal, QAfterSortBy>
      sortByByRemoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'byRemoteId', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal, QAfterSortBy>
      sortByByRemoteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'byRemoteId', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal, QAfterSortBy>
      sortByEmbeddingCipherVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'embeddingCipherVersion', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal, QAfterSortBy>
      sortByEmbeddingCipherVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'embeddingCipherVersion', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal, QAfterSortBy>
      sortByEmbeddingDeviceCipherVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'embeddingDeviceCipherVersion', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal, QAfterSortBy>
      sortByEmbeddingDeviceCipherVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'embeddingDeviceCipherVersion', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal, QAfterSortBy>
      sortByEmpleadoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'empleadoId', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal, QAfterSortBy>
      sortByEmpleadoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'empleadoId', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal, QAfterSortBy>
      sortByRemoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal, QAfterSortBy>
      sortByRemoteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal, QAfterSortBy>
      sortBySyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncedAt', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal, QAfterSortBy>
      sortBySyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncedAt', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension EmpleadoBiometriaLocalQuerySortThenBy on QueryBuilder<
    EmpleadoBiometriaLocal, EmpleadoBiometriaLocal, QSortThenBy> {
  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal, QAfterSortBy>
      thenByActivo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activo', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal, QAfterSortBy>
      thenByActivoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activo', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal, QAfterSortBy>
      thenByByRemoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'byRemoteId', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal, QAfterSortBy>
      thenByByRemoteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'byRemoteId', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal, QAfterSortBy>
      thenByEmbeddingCipherVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'embeddingCipherVersion', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal, QAfterSortBy>
      thenByEmbeddingCipherVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'embeddingCipherVersion', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal, QAfterSortBy>
      thenByEmbeddingDeviceCipherVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'embeddingDeviceCipherVersion', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal, QAfterSortBy>
      thenByEmbeddingDeviceCipherVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'embeddingDeviceCipherVersion', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal, QAfterSortBy>
      thenByEmpleadoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'empleadoId', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal, QAfterSortBy>
      thenByEmpleadoIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'empleadoId', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal, QAfterSortBy>
      thenByRemoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal, QAfterSortBy>
      thenByRemoteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal, QAfterSortBy>
      thenBySyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncedAt', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal, QAfterSortBy>
      thenBySyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncedAt', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension EmpleadoBiometriaLocalQueryWhereDistinct
    on QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal, QDistinct> {
  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal, QDistinct>
      distinctByActivo() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'activo');
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal, QDistinct>
      distinctByByRemoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'byRemoteId');
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal, QDistinct>
      distinctByEmbeddingLegacy() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'embedding');
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal, QDistinct>
      distinctByEmbeddingCipher() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'embeddingCipher');
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal, QDistinct>
      distinctByEmbeddingCipherVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'embeddingCipherVersion');
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal, QDistinct>
      distinctByEmbeddingDeviceLegacy() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'embeddingDevice');
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal, QDistinct>
      distinctByEmbeddingDeviceCipher() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'embeddingDeviceCipher');
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal, QDistinct>
      distinctByEmbeddingDeviceCipherVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'embeddingDeviceCipherVersion');
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal, QDistinct>
      distinctByEmpleadoId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'empleadoId');
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal, QDistinct>
      distinctByRemoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'remoteId');
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal, QDistinct>
      distinctBySyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncedAt');
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, EmpleadoBiometriaLocal, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension EmpleadoBiometriaLocalQueryProperty on QueryBuilder<
    EmpleadoBiometriaLocal, EmpleadoBiometriaLocal, QQueryProperty> {
  QueryBuilder<EmpleadoBiometriaLocal, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, bool, QQueryOperations>
      activoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activo');
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, int, QQueryOperations>
      byRemoteIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'byRemoteId');
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, List<double>?, QQueryOperations>
      embeddingLegacyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'embedding');
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, List<int>?, QQueryOperations>
      embeddingCipherProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'embeddingCipher');
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, int, QQueryOperations>
      embeddingCipherVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'embeddingCipherVersion');
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, List<double>?, QQueryOperations>
      embeddingDeviceLegacyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'embeddingDevice');
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, List<int>?, QQueryOperations>
      embeddingDeviceCipherProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'embeddingDeviceCipher');
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, int, QQueryOperations>
      embeddingDeviceCipherVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'embeddingDeviceCipherVersion');
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, int, QQueryOperations>
      empleadoIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'empleadoId');
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, int, QQueryOperations>
      remoteIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'remoteId');
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, DateTime?, QQueryOperations>
      syncedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncedAt');
    });
  }

  QueryBuilder<EmpleadoBiometriaLocal, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
