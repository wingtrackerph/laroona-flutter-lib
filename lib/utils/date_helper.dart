import 'package:intl/intl.dart';

const fullDateFormat = 'E MMM dd yyyy';
const fullDateTimeFormat = '$fullDateFormat h:mm a';

const defaultDateFormat = 'yyyy-MM-dd';
const defaultTimeFormat = "h:mm:ss a";
const defaultDateTimeFormat = '$defaultDateFormat $defaultTimeFormat';

const shortDateTimeFormat = "MMM dd, h:mm a";

const sqlDateTimeFormat = "yyyy-MM-dd HH:mm:ss";

DateTime? toDateTime(String? dateString) {
  if (dateString == null) {
    return null;
  }

  if (!dateString.endsWith('Z')) {
    dateString = '${dateString}Z';
  }

  return DateTime.tryParse(dateString)?.toLocal();
}

DateTime? toUtcDateTime(String? dateString) {
  if (dateString == null) {
    return null;
  }

  try {
    if (dateString.contains('/')) {
      return DateFormat('MM/dd/yyyy HH:mm:ss').parse(dateString).toUtc();
    }
    return DateFormat('$defaultDateFormat HH:mm:ss').parse(dateString).toUtc();
  } catch (_) {}
  return null;
}

String toFullDateTimeFormat(String? dateString) {
  if (dateString == null) {
    return '';
  }

  return toFullDateTimeFormatFromDate(toDateTime(dateString));
}

String toFullDateTimeFormatFromDate(DateTime? dateTime) {
  if (dateTime == null) {
    return '';
  }

  return DateFormat(fullDateTimeFormat).format(dateTime).toString();
}

String toFullDateFormatFromDate(DateTime? dateTime) {
  if (dateTime == null) {
    return '';
  }

  return DateFormat(fullDateFormat).format(dateTime).toString();
}

String toDefaultDateTimeFormatFromDate(DateTime? dateTime) {
  if (dateTime == null) {
    return '';
  }

  return DateFormat(defaultDateTimeFormat).format(dateTime).toString();
}

String toSqlDateTime(DateTime? dateTime) {
  if (dateTime == null) {
    return '';
  }

  return DateFormat(sqlDateTimeFormat).format(dateTime).toString();
}

String toDefaultDateFormat(String? dateString) {
  if (dateString == null) {
    return '';
  }

  return toDefaultDateFormatFromDate(toDateTime(dateString));
}

String toDefaultDateTimeFormat(String? dateString) {
  if (dateString == null) {
    return '';
  }

  return toDefaultDateTimeFormatFromDate(toDateTime(dateString));
}

String toDefaulTimeFormat(String? dateString) {
  if (dateString == null) {
    return '';
  }

  return toDefaultTimeFormatFromDate(toDateTime(dateString));
}

String toDefaultDateFormatFromDate(DateTime? dateTime) {
  if (dateTime == null) {
    return '';
  }

  return DateFormat(defaultDateFormat).format(dateTime).toString();
}

String toDefaultTimeFormatFromDate(DateTime? dateTime) {
  if (dateTime == null) {
    return '';
  }

  return DateFormat(defaultTimeFormat).format(dateTime).toString();
}

bool isBeforeToday(String? dateString) {
  if (dateString == null) {
    return false;
  }

  final dateTime = toDateTime(dateString);
  if (dateTime == null) {
    return false;
  }

  return dateTime.isBefore(DateTime.now());
}

bool isAfterToday(String? dateString) {
  if (dateString == null) {
    return false;
  }

  final dateTime = toDateTime(dateString);
  if (dateTime == null) {
    return false;
  }

  return dateTime.isAfter(DateTime.now());
}

String toAMPMTime(DateTime time) {
  final hour = time.hour;
  final minute = time.minute;
  final second = time.second;
  final period = hour >= 12 ? 'PM' : 'AM';
  final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
  return '$displayHour:${minute.toString().padLeft(2, '0')}:${second.toString().padLeft(2, '0')} $period';
}

String toShortAMPMTime(DateTime time) {
  final hour = time.hour;
  final minute = time.minute;
  final period = hour >= 12 ? 'PM' : 'AM';
  final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
  return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
}

String toAMPMTimeIfSameDay(String? dateString, DateTime? dateToCompare) {
  if (dateString == null || dateToCompare == null) {
    return '';
  }

  final dateTime = toDateTime(dateString);
  if (dateTime == null) {
    return '';
  }

  if (dateTime.year == dateToCompare.year &&
      dateTime.month == dateToCompare.month &&
      dateTime.day == dateToCompare.day) {
    return toAMPMTime(dateTime);
  }

  return DateFormat('MM/dd h:mm:ssa').format(dateTime).toString();
}

String toShortDateTimeFormat(String? dateString) {
  if (dateString == null) {
    return '';
  }

  final dateTime = toDateTime(dateString);
  if (dateTime == null) {
    return '';
  }

  return DateFormat(shortDateTimeFormat).format(dateTime).toString();
}

bool isValidDate(String value, String separator) {
  if (value.isEmpty) {
    return false;
  }

  if (value.contains(' ')) {
    value = value.split(' ')[0];
  }

  if (value.length != 10 || value.split(separator).length != 3) {
    return false;
  }

  return true;
}

bool isValidTime(String value) {
  if (value.isEmpty) {
    return false;
  }

  if (value.contains(' ')) {
    final splitted = value.split(' ');
    if (splitted.length != 2) {
      return false;
    }
    value = value.split(' ')[1];
  }

  if (value.length != 8) {
    return false;
  }

  return true;
}

String convertUiDateToSqlDate(String date) {
  if (!isValidDate(date, '/')) {
    return date;
  }

  final dateSplitted = date.split('/');
  return '${dateSplitted[2]}-${dateSplitted[0]}-${dateSplitted[1]}';
}

String convertSqlDateToUiDate(String date) {
  if (!isValidDate(date, '-')) {
    return date;
  }

  if (date.contains(' ')) {
    // If it has space, it means it has time and timezone
    // Convert to DateTime first
    final dateTime = toDateTime(date);
    if (dateTime != null) {
      // Format date to YYYY-MM-DD format
      date =
          '${dateTime.year.toString().padLeft(4, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    } else {
      // If conversion fails, just take the date part
      date = date.split(' ')[0];
    }
  }

  final dateSplitted = date.split('-');
  return '${dateSplitted[1]}/${dateSplitted[2]}/${dateSplitted[0]}';
}

String convertSqlDateToUiTime(String date) {
  if (!isValidTime(date)) {
    return date;
  }

  if (date.contains(' ')) {
    // If it has space, it means it has time and timezone
    // Convert to DateTime first
    final dateTime = toDateTime(date);
    if (dateTime != null) {
      // Format time to HH:MM:SS format
      return DateFormat('HH:mm:ss').format(dateTime).toString();
    }
    return date;
  }

  return date;
}
