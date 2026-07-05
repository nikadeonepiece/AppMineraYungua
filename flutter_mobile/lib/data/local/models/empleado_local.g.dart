// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'empleado_local.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetEmpleadoLocalCollection on Isar {
  IsarCollection<EmpleadoLocal> get empleadoLocals => this.collection();
}

const EmpleadoLocalSchema = CollectionSchema(
  name: r'EmpleadoLocal',
  id: -657752157131753093,
  properties: {
    r'activo': PropertySchema(
      id: 0,
      name: r'activo',
      type: IsarType.bool,
    ),
    r'apellidos': PropertySchema(
      id: 1,
      name: r'apellidos',
      type: IsarType.string,
    ),
    r'area': PropertySchema(
      id: 2,
      name: r'area',
      type: IsarType.string,
    ),
    r'byRemoteId': PropertySchema(
      id: 3,
      name: r'byRemoteId',
      type: IsarType.long,
    ),
    r'cargo': PropertySchema(
      id: 4,
      name: r'cargo',
      type: IsarType.string,
    ),
    r'codigoEmpleado': PropertySchema(
      id: 5,
      name: r'codigoEmpleado',
      type: IsarType.string,
    ),
    r'dni': PropertySchema(
      id: 6,
      name: r'dni',
      type: IsarType.string,
    ),
    r'nombres': PropertySchema(
      id: 7,
      name: r'nombres',
      type: IsarType.string,
    ),
    r'remoteId': PropertySchema(
      id: 8,
      name: r'remoteId',
      type: IsarType.long,
    ),
    r'remoteUuid': PropertySchema(
      id: 9,
      name: r'remoteUuid',
      type: IsarType.string,
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
  estimateSize: _empleadoLocalEstimateSize,
  serialize: _empleadoLocalSerialize,
  deserialize: _empleadoLocalDeserialize,
  deserializeProp: _empleadoLocalDeserializeProp,
  idName: r'id',
  indexes: {
    r'dni': IndexSchema(
      id: 7716107859896601784,
      name: r'dni',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'dni',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'codigoEmpleado': IndexSchema(
      id: 1310493510112800221,
      name: r'codigoEmpleado',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'codigoEmpleado',
          type: IndexType.hash,
          caseSensitive: true,
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
  getId: _empleadoLocalGetId,
  getLinks: _empleadoLocalGetLinks,
  attach: _empleadoLocalAttach,
  version: '3.1.0+1',
);

int _empleadoLocalEstimateSize(
  EmpleadoLocal object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.apellidos.length * 3;
  bytesCount += 3 + object.area.length * 3;
  bytesCount += 3 + object.cargo.length * 3;
  bytesCount += 3 + object.codigoEmpleado.length * 3;
  bytesCount += 3 + object.dni.length * 3;
  bytesCount += 3 + object.nombres.length * 3;
  bytesCount += 3 + object.remoteUuid.length * 3;
  return bytesCount;
}

void _empleadoLocalSerialize(
  EmpleadoLocal object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeBool(offsets[0], object.activo);
  writer.writeString(offsets[1], object.apellidos);
  writer.writeString(offsets[2], object.area);
  writer.writeLong(offsets[3], object.byRemoteId);
  writer.writeString(offsets[4], object.cargo);
  writer.writeString(offsets[5], object.codigoEmpleado);
  writer.writeString(offsets[6], object.dni);
  writer.writeString(offsets[7], object.nombres);
  writer.writeLong(offsets[8], object.remoteId);
  writer.writeString(offsets[9], object.remoteUuid);
  writer.writeDateTime(offsets[10], object.syncedAt);
  writer.writeDateTime(offsets[11], object.updatedAt);
}

EmpleadoLocal _empleadoLocalDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = EmpleadoLocal();
  object.activo = reader.readBool(offsets[0]);
  object.apellidos = reader.readString(offsets[1]);
  object.area = reader.readString(offsets[2]);
  object.cargo = reader.readString(offsets[4]);
  object.codigoEmpleado = reader.readString(offsets[5]);
  object.dni = reader.readString(offsets[6]);
  object.id = id;
  object.nombres = reader.readString(offsets[7]);
  object.remoteId = reader.readLong(offsets[8]);
  object.remoteUuid = reader.readString(offsets[9]);
  object.syncedAt = reader.readDateTimeOrNull(offsets[10]);
  object.updatedAt = reader.readDateTime(offsets[11]);
  return object;
}

P _empleadoLocalDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readBool(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readString(offset)) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 11:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _empleadoLocalGetId(EmpleadoLocal object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _empleadoLocalGetLinks(EmpleadoLocal object) {
  return [];
}

void _empleadoLocalAttach(
    IsarCollection<dynamic> col, Id id, EmpleadoLocal object) {
  object.id = id;
}

extension EmpleadoLocalByIndex on IsarCollection<EmpleadoLocal> {
  Future<EmpleadoLocal?> getByByRemoteId(int byRemoteId) {
    return getByIndex(r'byRemoteId', [byRemoteId]);
  }

  EmpleadoLocal? getByByRemoteIdSync(int byRemoteId) {
    return getByIndexSync(r'byRemoteId', [byRemoteId]);
  }

  Future<bool> deleteByByRemoteId(int byRemoteId) {
    return deleteByIndex(r'byRemoteId', [byRemoteId]);
  }

  bool deleteByByRemoteIdSync(int byRemoteId) {
    return deleteByIndexSync(r'byRemoteId', [byRemoteId]);
  }

  Future<List<EmpleadoLocal?>> getAllByByRemoteId(List<int> byRemoteIdValues) {
    final values = byRemoteIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'byRemoteId', values);
  }

  List<EmpleadoLocal?> getAllByByRemoteIdSync(List<int> byRemoteIdValues) {
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

  Future<Id> putByByRemoteId(EmpleadoLocal object) {
    return putByIndex(r'byRemoteId', object);
  }

  Id putByByRemoteIdSync(EmpleadoLocal object, {bool saveLinks = true}) {
    return putByIndexSync(r'byRemoteId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByByRemoteId(List<EmpleadoLocal> objects) {
    return putAllByIndex(r'byRemoteId', objects);
  }

  List<Id> putAllByByRemoteIdSync(List<EmpleadoLocal> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'byRemoteId', objects, saveLinks: saveLinks);
  }
}

extension EmpleadoLocalQueryWhereSort
    on QueryBuilder<EmpleadoLocal, EmpleadoLocal, QWhere> {
  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterWhere> anyByRemoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'byRemoteId'),
      );
    });
  }
}

extension EmpleadoLocalQueryWhere
    on QueryBuilder<EmpleadoLocal, EmpleadoLocal, QWhereClause> {
  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterWhereClause> idBetween(
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

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterWhereClause> dniEqualTo(
      String dni) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'dni',
        value: [dni],
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterWhereClause> dniNotEqualTo(
      String dni) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dni',
              lower: [],
              upper: [dni],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dni',
              lower: [dni],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dni',
              lower: [dni],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'dni',
              lower: [],
              upper: [dni],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterWhereClause>
      codigoEmpleadoEqualTo(String codigoEmpleado) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'codigoEmpleado',
        value: [codigoEmpleado],
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterWhereClause>
      codigoEmpleadoNotEqualTo(String codigoEmpleado) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'codigoEmpleado',
              lower: [],
              upper: [codigoEmpleado],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'codigoEmpleado',
              lower: [codigoEmpleado],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'codigoEmpleado',
              lower: [codigoEmpleado],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'codigoEmpleado',
              lower: [],
              upper: [codigoEmpleado],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterWhereClause>
      byRemoteIdEqualTo(int byRemoteId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'byRemoteId',
        value: [byRemoteId],
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterWhereClause>
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

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterWhereClause>
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

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterWhereClause>
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

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterWhereClause>
      byRemoteIdBetween(
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

extension EmpleadoLocalQueryFilter
    on QueryBuilder<EmpleadoLocal, EmpleadoLocal, QFilterCondition> {
  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      activoEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'activo',
        value: value,
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      apellidosEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'apellidos',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      apellidosGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'apellidos',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      apellidosLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'apellidos',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      apellidosBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'apellidos',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      apellidosStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'apellidos',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      apellidosEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'apellidos',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      apellidosContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'apellidos',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      apellidosMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'apellidos',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      apellidosIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'apellidos',
        value: '',
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      apellidosIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'apellidos',
        value: '',
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition> areaEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'area',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      areaGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'area',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      areaLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'area',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition> areaBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'area',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      areaStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'area',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      areaEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'area',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      areaContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'area',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition> areaMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'area',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      areaIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'area',
        value: '',
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      areaIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'area',
        value: '',
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      byRemoteIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'byRemoteId',
        value: value,
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
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

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
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

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
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

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      cargoEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cargo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      cargoGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cargo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      cargoLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cargo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      cargoBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cargo',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      cargoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'cargo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      cargoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'cargo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      cargoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'cargo',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      cargoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'cargo',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      cargoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cargo',
        value: '',
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      cargoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cargo',
        value: '',
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      codigoEmpleadoEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'codigoEmpleado',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      codigoEmpleadoGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'codigoEmpleado',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      codigoEmpleadoLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'codigoEmpleado',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      codigoEmpleadoBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'codigoEmpleado',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      codigoEmpleadoStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'codigoEmpleado',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      codigoEmpleadoEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'codigoEmpleado',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      codigoEmpleadoContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'codigoEmpleado',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      codigoEmpleadoMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'codigoEmpleado',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      codigoEmpleadoIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'codigoEmpleado',
        value: '',
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      codigoEmpleadoIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'codigoEmpleado',
        value: '',
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition> dniEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dni',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      dniGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dni',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition> dniLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dni',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition> dniBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dni',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      dniStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'dni',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition> dniEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'dni',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition> dniContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'dni',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition> dniMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'dni',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      dniIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dni',
        value: '',
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      dniIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'dni',
        value: '',
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition> idBetween(
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

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      nombresEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nombres',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      nombresGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'nombres',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      nombresLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'nombres',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      nombresBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'nombres',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      nombresStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'nombres',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      nombresEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'nombres',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      nombresContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'nombres',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      nombresMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'nombres',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      nombresIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'nombres',
        value: '',
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      nombresIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'nombres',
        value: '',
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      remoteIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'remoteId',
        value: value,
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
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

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
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

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
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

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      remoteUuidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'remoteUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      remoteUuidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'remoteUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      remoteUuidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'remoteUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      remoteUuidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'remoteUuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      remoteUuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'remoteUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      remoteUuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'remoteUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      remoteUuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'remoteUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      remoteUuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'remoteUuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      remoteUuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'remoteUuid',
        value: '',
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      remoteUuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'remoteUuid',
        value: '',
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      syncedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'syncedAt',
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      syncedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'syncedAt',
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      syncedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
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

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
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

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
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

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
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

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
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

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterFilterCondition>
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
}

extension EmpleadoLocalQueryObject
    on QueryBuilder<EmpleadoLocal, EmpleadoLocal, QFilterCondition> {}

extension EmpleadoLocalQueryLinks
    on QueryBuilder<EmpleadoLocal, EmpleadoLocal, QFilterCondition> {}

extension EmpleadoLocalQuerySortBy
    on QueryBuilder<EmpleadoLocal, EmpleadoLocal, QSortBy> {
  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterSortBy> sortByActivo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activo', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterSortBy> sortByActivoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activo', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterSortBy> sortByApellidos() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'apellidos', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterSortBy>
      sortByApellidosDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'apellidos', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterSortBy> sortByArea() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'area', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterSortBy> sortByAreaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'area', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterSortBy> sortByByRemoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'byRemoteId', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterSortBy>
      sortByByRemoteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'byRemoteId', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterSortBy> sortByCargo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cargo', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterSortBy> sortByCargoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cargo', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterSortBy>
      sortByCodigoEmpleado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codigoEmpleado', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterSortBy>
      sortByCodigoEmpleadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codigoEmpleado', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterSortBy> sortByDni() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dni', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterSortBy> sortByDniDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dni', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterSortBy> sortByNombres() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombres', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterSortBy> sortByNombresDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombres', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterSortBy> sortByRemoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterSortBy>
      sortByRemoteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterSortBy> sortByRemoteUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteUuid', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterSortBy>
      sortByRemoteUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteUuid', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterSortBy> sortBySyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncedAt', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterSortBy>
      sortBySyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncedAt', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension EmpleadoLocalQuerySortThenBy
    on QueryBuilder<EmpleadoLocal, EmpleadoLocal, QSortThenBy> {
  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterSortBy> thenByActivo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activo', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterSortBy> thenByActivoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'activo', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterSortBy> thenByApellidos() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'apellidos', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterSortBy>
      thenByApellidosDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'apellidos', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterSortBy> thenByArea() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'area', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterSortBy> thenByAreaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'area', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterSortBy> thenByByRemoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'byRemoteId', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterSortBy>
      thenByByRemoteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'byRemoteId', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterSortBy> thenByCargo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cargo', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterSortBy> thenByCargoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cargo', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterSortBy>
      thenByCodigoEmpleado() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codigoEmpleado', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterSortBy>
      thenByCodigoEmpleadoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'codigoEmpleado', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterSortBy> thenByDni() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dni', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterSortBy> thenByDniDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dni', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterSortBy> thenByNombres() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombres', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterSortBy> thenByNombresDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'nombres', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterSortBy> thenByRemoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterSortBy>
      thenByRemoteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteId', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterSortBy> thenByRemoteUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteUuid', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterSortBy>
      thenByRemoteUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'remoteUuid', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterSortBy> thenBySyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncedAt', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterSortBy>
      thenBySyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncedAt', Sort.desc);
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension EmpleadoLocalQueryWhereDistinct
    on QueryBuilder<EmpleadoLocal, EmpleadoLocal, QDistinct> {
  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QDistinct> distinctByActivo() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'activo');
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QDistinct> distinctByApellidos(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'apellidos', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QDistinct> distinctByArea(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'area', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QDistinct> distinctByByRemoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'byRemoteId');
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QDistinct> distinctByCargo(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cargo', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QDistinct>
      distinctByCodigoEmpleado({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'codigoEmpleado',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QDistinct> distinctByDni(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dni', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QDistinct> distinctByNombres(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'nombres', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QDistinct> distinctByRemoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'remoteId');
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QDistinct> distinctByRemoteUuid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'remoteUuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QDistinct> distinctBySyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncedAt');
    });
  }

  QueryBuilder<EmpleadoLocal, EmpleadoLocal, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension EmpleadoLocalQueryProperty
    on QueryBuilder<EmpleadoLocal, EmpleadoLocal, QQueryProperty> {
  QueryBuilder<EmpleadoLocal, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<EmpleadoLocal, bool, QQueryOperations> activoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'activo');
    });
  }

  QueryBuilder<EmpleadoLocal, String, QQueryOperations> apellidosProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'apellidos');
    });
  }

  QueryBuilder<EmpleadoLocal, String, QQueryOperations> areaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'area');
    });
  }

  QueryBuilder<EmpleadoLocal, int, QQueryOperations> byRemoteIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'byRemoteId');
    });
  }

  QueryBuilder<EmpleadoLocal, String, QQueryOperations> cargoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cargo');
    });
  }

  QueryBuilder<EmpleadoLocal, String, QQueryOperations>
      codigoEmpleadoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'codigoEmpleado');
    });
  }

  QueryBuilder<EmpleadoLocal, String, QQueryOperations> dniProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dni');
    });
  }

  QueryBuilder<EmpleadoLocal, String, QQueryOperations> nombresProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'nombres');
    });
  }

  QueryBuilder<EmpleadoLocal, int, QQueryOperations> remoteIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'remoteId');
    });
  }

  QueryBuilder<EmpleadoLocal, String, QQueryOperations> remoteUuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'remoteUuid');
    });
  }

  QueryBuilder<EmpleadoLocal, DateTime?, QQueryOperations> syncedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncedAt');
    });
  }

  QueryBuilder<EmpleadoLocal, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
