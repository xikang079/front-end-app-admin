// Model cho thống kê dữ liệu
class DataStatistics {
  final int crabPurchases;
  final int dailySummaries;
  final double totalRevenue;
  final double? totalWeight;
  final DateRange? dateRange;
  final String? warning;
  final String? currentTime;
  final FilterInfo? filter;

  DataStatistics({
    required this.crabPurchases,
    required this.dailySummaries,
    required this.totalRevenue,
    this.totalWeight,
    this.dateRange,
    this.warning,
    this.currentTime,
    this.filter,
  });

  factory DataStatistics.fromJson(Map<String, dynamic> json) {
    return DataStatistics(
      crabPurchases: json['crabPurchases'] ?? 0,
      dailySummaries: json['dailySummaries'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      totalWeight: json['totalWeight']?.toDouble(),
      dateRange: json['dateRange'] != null
          ? DateRange.fromJson(json['dateRange'])
          : null,
      warning: json['warning'],
    );
  }
}

class FilterInfo {
  final String depotId;
  final String startDate;
  final String endDate;

  FilterInfo({
    required this.depotId,
    required this.startDate,
    required this.endDate,
  });

  factory FilterInfo.fromJson(Map<String, dynamic> json) {
    return FilterInfo(
      depotId: json['depotId'] ?? 'all',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
    );
  }
}

class DateRange {
  final String oldest;
  final String newest;

  DateRange({
    required this.oldest,
    required this.newest,
  });

  factory DateRange.fromJson(Map<String, dynamic> json) {
    return DateRange(
      oldest: json['oldest']?.toString() ?? '',
      newest: json['newest']?.toString() ?? '',
    );
  }
}

// Model cho kết quả xóa dữ liệu
class DeleteResult {
  final int crabPurchasesDeleted;
  final int dailySummariesDeleted;
  final BackupInfo? backup;
  final String? scope;
  final String? message;
  final String? deletedAt;
  final int? totalChunks;

  DeleteResult({
    required this.crabPurchasesDeleted,
    required this.dailySummariesDeleted,
    this.backup,
    this.scope,
    this.message,
    this.deletedAt,
    this.totalChunks,
  });

  factory DeleteResult.fromJson(Map<String, dynamic> json) {
    final deleted = json['deleted'] ?? {};
    return DeleteResult(
      crabPurchasesDeleted: deleted['crabPurchases'] ?? 0,
      dailySummariesDeleted: deleted['dailySummaries'] ?? 0,
      backup: json['backup'] != null ? BackupInfo.fromJson(json['backup']) : null,
      scope: json['scope'],
      message: json['message'],
      deletedAt: json['deletedAt'],
      totalChunks: json['totalChunks'],
    );
  }
}

// Model cho thông tin backup (MongoDB với hỗ trợ chunking)
class BackupInfo {
  final String backupId;
  final String fileName;
  final String? createdAt;
  final String? size;
  final String? type;
  final String? depotId;
  final int? totalPurchases;
  final int? totalSummaries;
  final double? totalRevenue;
  final DateRange? dateRange;
  // Chunking support
  final bool isChunked;
  final int? totalChunks;
  final int? chunkIndex;
  final String? mainBackupId;

  BackupInfo({
    required this.backupId,
    required this.fileName,
    this.createdAt,
    this.size,
    this.type,
    this.depotId,
    this.totalPurchases,
    this.totalSummaries,
    this.totalRevenue,
    this.dateRange,
    this.isChunked = false,
    this.totalChunks,
    this.chunkIndex,
    this.mainBackupId,
  });

  factory BackupInfo.fromJson(Map<String, dynamic> json) {
    return BackupInfo(
      backupId: json['backupId'] ?? json['id'] ?? json['_id'] ?? '',
      fileName: json['fileName'] ?? json['name'] ?? '',
      createdAt: json['createdAt']?.toString(),
      size: json['size']?.toString(),
      type: json['type'],
      depotId: json['depotId']?.toString(),
      totalPurchases: json['totalPurchases'],
      totalSummaries: json['totalSummaries'],
      totalRevenue: json['totalRevenue']?.toDouble(),
      dateRange: json['dateRange'] != null 
          ? DateRange.fromJson(json['dateRange']) 
          : null,
      isChunked: json['isChunked'] ?? false,
      totalChunks: json['totalChunks'],
      chunkIndex: json['chunkIndex'],
      mainBackupId: json['mainBackupId'],
    );
  }

  // Kiểm tra xem có phải là chunk phụ không (không phải chunk đầu tiên)
  bool get isSubChunk => isChunked && chunkIndex != null && chunkIndex! > 1;
}

// Model cho preview backup
class BackupPreview {
  final BackupInfo backup;
  final BackupMetadata metadata;
  final List<DateBreakdown>? dateBreakdown;
  final ChunkInfo? chunkInfo;

  BackupPreview({
    required this.backup,
    required this.metadata,
    this.dateBreakdown,
    this.chunkInfo,
  });

  factory BackupPreview.fromJson(Map<String, dynamic> json) {
    final backupData = json['backup'] ?? {};
    final metadataData = json['metadata'] ?? {};
    
    List<DateBreakdown>? breakdown;
    if (json['dateBreakdown'] != null) {
      breakdown = (json['dateBreakdown'] as List)
          .map((item) => DateBreakdown.fromJson(item))
          .toList();
    }

    return BackupPreview(
      backup: BackupInfo.fromJson(backupData),
      metadata: BackupMetadata.fromJson(metadataData),
      dateBreakdown: breakdown,
      chunkInfo: json['chunkInfo'] != null 
          ? ChunkInfo.fromJson(json['chunkInfo']) 
          : null,
    );
  }
}

class ChunkInfo {
  final bool isChunked;
  final int totalChunks;
  final String totalSize;

  ChunkInfo({
    required this.isChunked,
    required this.totalChunks,
    required this.totalSize,
  });

  factory ChunkInfo.fromJson(Map<String, dynamic> json) {
    return ChunkInfo(
      isChunked: json['isChunked'] ?? false,
      totalChunks: json['totalChunks'] ?? 1,
      totalSize: json['totalSize'] ?? '',
    );
  }
}

class BackupMetadata {
  final String? depotId;
  final DateRange? dateRange;
  final int totalPurchases;
  final int totalSummaries;
  final double totalRevenue;

  BackupMetadata({
    this.depotId,
    this.dateRange,
    required this.totalPurchases,
    required this.totalSummaries,
    required this.totalRevenue,
  });

  factory BackupMetadata.fromJson(Map<String, dynamic> json) {
    return BackupMetadata(
      depotId: json['depotId']?.toString(),
      dateRange: json['dateRange'] != null 
          ? DateRange.fromJson(json['dateRange']) 
          : null,
      totalPurchases: json['totalPurchases'] ?? 0,
      totalSummaries: json['totalSummaries'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
    );
  }
}

// Model cho breakdown theo ngày trong preview
class DateBreakdown {
  final String date;
  final int purchases;
  final int summaries;
  final double revenue;

  DateBreakdown({
    required this.date,
    required this.purchases,
    required this.summaries,
    required this.revenue,
  });

  factory DateBreakdown.fromJson(Map<String, dynamic> json) {
    return DateBreakdown(
      date: json['date'] ?? '',
      purchases: json['purchases'] ?? 0,
      summaries: json['summaries'] ?? 0,
      revenue: (json['revenue'] ?? 0).toDouble(),
    );
  }
}

// Model cho kết quả khôi phục
class RestoreResult {
  final int crabPurchasesRestored;
  final int dailySummariesRestored;
  final int crabPurchasesSkipped;
  final int dailySummariesSkipped;
  final String? restoredAt;
  final String? backupId;
  final int? chunksProcessed;

  RestoreResult({
    required this.crabPurchasesRestored,
    required this.dailySummariesRestored,
    this.crabPurchasesSkipped = 0,
    this.dailySummariesSkipped = 0,
    this.restoredAt,
    this.backupId,
    this.chunksProcessed,
  });

  factory RestoreResult.fromJson(Map<String, dynamic> json) {
    final results = json['results'] ?? {};
    final crabPurchases = results['crabPurchases'] ?? {};
    final dailySummaries = results['dailySummaries'] ?? {};

    return RestoreResult(
      crabPurchasesRestored: crabPurchases['restored'] ?? 0,
      dailySummariesRestored: dailySummaries['restored'] ?? 0,
      crabPurchasesSkipped: crabPurchases['skipped'] ?? 0,
      dailySummariesSkipped: dailySummaries['skipped'] ?? 0,
      restoredAt: json['restoredAt'],
      backupId: json['backupId'],
      chunksProcessed: json['chunksProcessed'],
    );
  }
}

// Enum cho các chế độ xóa
enum DeleteMode {
  all,
  today,
  exceptToday,
  custom,
  byDate,
}

extension DeleteModeExtension on DeleteMode {
  String get endpoint {
    switch (this) {
      case DeleteMode.all:
        return '/delete/all';
      case DeleteMode.today:
        return '/delete/today';
      case DeleteMode.exceptToday:
        return '/delete/except-today';
      case DeleteMode.custom:
        return '/delete/custom';
      case DeleteMode.byDate:
        return '/delete/by-date';
    }
  }

  String get displayName {
    switch (this) {
      case DeleteMode.all:
        return 'Xóa tất cả';
      case DeleteMode.today:
        return 'Xóa hôm nay';
      case DeleteMode.exceptToday:
        return 'Xóa tất cả trừ hôm nay';
      case DeleteMode.custom:
        return 'Xóa tùy chọn thời gian';
      case DeleteMode.byDate:
        return 'Xóa theo ngày cụ thể';
    }
  }

  String get description {
    switch (this) {
      case DeleteMode.all:
        return 'Xóa toàn bộ dữ liệu hóa đơn và báo cáo';
      case DeleteMode.today:
        return 'Chỉ xóa dữ liệu của ngày hôm nay (6h sáng → 6h sáng mai)';
      case DeleteMode.exceptToday:
        return 'Giữ lại dữ liệu hôm nay, xóa các ngày trước';
      case DeleteMode.custom:
        return 'Chọn khoảng thời gian để xóa';
      case DeleteMode.byDate:
        return 'Xóa dữ liệu của một ngày cụ thể';
    }
  }
}
