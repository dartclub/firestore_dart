## 0.0.20

- ignore attributes that are null in serialisation

## 0.0.19

- reintroduce Timestamp support

## 0.0.18

- `nullable` field for `FirestoreDocument`
- fix deserialization of List and Set with generic types (e.g. `List<String>`)

## 0.0.17

- better handling of null values during (de)serialization
- fixed bug #21 generator now ignores getters in `fromSnapshot`/`fromMap` and setters in `toMap`

## 0.0.15

- revert flutter form support introduced in v. 0.0.4

## 0.0.12 - 0.0.14

- bug fixes

## 0.0.11

- add missing String type conversion in .fromSnapshot & .fromMap methods

## 0.0.10

- bugfix for Timestamps

## 0.0.9

- support for Timestamp and DateTime, type fix with submodels

## 0.0.8

## 0.0.7

- fix type checking for forms (see [https://github.com/dartclub/firestore_dart/issues/20])

## 0.0.6

- improved form support (see [https://github.com/dartclub/firestore_dart/issues/20])

## 0.0.5

- more form support (see [https://github.com/dartclub/firestore_dart/issues/20])

## 0.0.4

- flutter form support

## 0.0.3

- unit tests, better generators, nullable is implemented

## 0.0.2

- example, fixed generators

## 0.0.1

- Initial version, unstable
