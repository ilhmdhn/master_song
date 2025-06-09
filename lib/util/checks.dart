import 'dart:io';

bool isNullOrEmpty(value) {
  return value == null || (value ?? '').trim().isEmpty;
}

bool isNotNullOrEmpty(value) {
  return value != null && value.trim().isNotEmpty;
}

bool isNotNullOrEmptyList(List<dynamic>? value) {
  return value != null && value.isNotEmpty;
}

bool isFileExist(String? path) {
  if (isNullOrEmpty(path)) {
    return false;
  }

  File file = File(path!);

  if (file.existsSync()) {
    return true;
  } else {
    return false;
  }
}
