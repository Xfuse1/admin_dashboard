import 'package:intl/intl.dart';

/// Date and time formatting utilities.
abstract final class DateFormatter {
  /// Arabic locale for date formatting.
  static const String _locale = 'ar';

  /// Formats date as "dd/MM/yyyy"
  static String date(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy', _locale).format(dateTime);
  }

  /// Formats date as "dd MMM yyyy" (e.g., "20 يناير 2026")
  static String dateFull(DateTime dateTime) {
    return DateFormat('dd MMM yyyy', _locale).format(dateTime);
  }

  /// Formats time as "hh:mm a" (e.g., "05:30 م")
  static String time(DateTime dateTime) {
    return DateFormat('hh:mm a', _locale).format(dateTime);
  }

  /// Formats date and time as "dd/MM/yyyy hh:mm a"
  static String dateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy hh:mm a', _locale).format(dateTime);
  }

  /// Formats date and time with seconds "dd/MM/yyyy hh:mm:ss a"
  static String dateTimeWithSeconds(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy hh:mm:ss a', _locale).format(dateTime);
  }

  /// Formats as relative time (e.g., "منذ 5 دقائق")
  static String relative(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      if (minutes == 1) return 'منذ دقيقة';
      if (minutes == 2) return 'منذ دقيقتين';
      if (minutes > 2 && minutes < 11) return 'منذ $minutes دقائق';
      return 'منذ $minutes دقيقة';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      if (hours == 1) return 'منذ ساعة';
      if (hours == 2) return 'منذ ساعتين';
      if (hours > 2 && hours < 11) return 'منذ $hours ساعات';
      return 'منذ $hours ساعة';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      if (days == 1) return 'منذ يوم';
      if (days == 2) return 'منذ يومين';
      if (days > 2 && days < 11) return 'منذ $days أيام';
      return 'منذ $days يوم';
    } else {
      return date(dateTime);
    }
  }

  /// Formats as day name (e.g., "الإثنين")
  static String dayName(DateTime dateTime) {
    return DateFormat('EEEE', _locale).format(dateTime);
  }

  /// Formats as month name (e.g., "يناير")
  static String monthName(DateTime dateTime) {
    return DateFormat('MMMM', _locale).format(dateTime);
  }

  /// Formats as day/month (e.g., "15/01")
  static String dayMonth(DateTime dateTime) {
    return DateFormat('dd/MM', _locale).format(dateTime);
  }

  /// Checks if date is today.
  static bool isToday(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }

  /// Checks if date is yesterday.
  static bool isYesterday(DateTime dateTime) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return dateTime.year == yesterday.year &&
        dateTime.month == yesterday.month &&
        dateTime.day == yesterday.day;
  }

  /// Formats as "اليوم", "أمس", or date.
  static String smart(DateTime dt) {
    if (isToday(dt)) {
      return 'اليوم ${time(dt)}';
    } else if (isYesterday(dt)) {
      return 'أمس ${time(dt)}';
    } else {
      return dateTime(dt);
    }
  }
}

/// Number formatting utilities.
abstract final class NumberFormatter {
  /// Formats number with thousand separators.
  static String format(num number) {
    return NumberFormat('#,###', 'ar').format(number);
  }

  /// Formats as currency (EGP).
  static String currency(num amount) {
    return NumberFormat.currency(
      locale: 'ar_EG',
      symbol: 'ج.م ',
      decimalDigits: 2,
    ).format(amount);
  }

  /// Formats as compact number (e.g., "1.2K", "3.5M").
  static String compact(num number) {
    return NumberFormat.compact(locale: 'ar').format(number);
  }

  /// Formats as compact currency.
  static String compactCurrency(num amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M ج.م';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K ج.م';
    }
    return currency(amount);
  }

  /// Formats as percentage.
  static String percentage(num value, {int decimals = 1}) {
    return '${value.toStringAsFixed(decimals)}%';
  }

  /// Formats order number with leading zeros.
  static String orderNumber(int number) {
    return '#${number.toString().padLeft(6, '0')}';
  }
}

/// Unified formatters facade for easy access.
abstract final class Formatters {
  // Number formatters
  static String number(num value) => NumberFormatter.format(value);
  static String currency(num amount) => NumberFormatter.currency(amount);
  static String compactCurrency(num amount) =>
      NumberFormatter.compactCurrency(amount);
  static String compact(num value) => NumberFormatter.compact(value);
  static String percentage(num value, {int decimals = 1}) =>
      NumberFormatter.percentage(value, decimals: decimals);

  // Date formatters
  static String date(DateTime dt) => DateFormatter.date(dt);
  static String dateFull(DateTime dt) => DateFormatter.dateFull(dt);
  static String time(DateTime dt) => DateFormatter.time(dt);
  static String dateTime(DateTime dt) => DateFormatter.dateTime(dt);
  static String dateTimeWithSeconds(DateTime dt) =>
      DateFormatter.dateTimeWithSeconds(dt);
  static String timeAgo(DateTime dt) => DateFormatter.relative(dt);
  static String formatRelativeTime(DateTime dt) => DateFormatter.relative(dt);
  static String formatDateTime(DateTime dt) => DateFormatter.dateTime(dt);
  static String dayMonth(DateTime dt) => DateFormatter.dayMonth(dt);

  /// Format duration in minutes to human readable format
  static String formatDuration(int minutes) {
    if (minutes < 1) {
      return 'أقل من دقيقة';
    } else if (minutes == 1) {
      return 'دقيقة واحدة';
    } else if (minutes == 2) {
      return 'دقيقتان';
    } else if (minutes < 60) {
      if (minutes > 2 && minutes < 11) {
        return '$minutes دقائق';
      }
      return '$minutes دقيقة';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;

      if (hours == 1) {
        if (remainingMinutes == 0) return 'ساعة واحدة';
        return 'ساعة و $remainingMinutes دقيقة';
      } else if (hours == 2) {
        if (remainingMinutes == 0) return 'ساعتان';
        return 'ساعتان و $remainingMinutes دقيقة';
      } else {
        final hourText =
            hours > 2 && hours < 11 ? '$hours ساعات' : '$hours ساعة';
        if (remainingMinutes == 0) return hourText;
        return '$hourText و $remainingMinutes دقيقة';
      }
    }
  }
}
