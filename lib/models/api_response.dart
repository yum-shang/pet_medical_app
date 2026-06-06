class ApiResponse<T> {
  final int code;
  final String message;
  final T? data;

  ApiResponse({required this.code, required this.message, this.data});

  bool get isSuccess => code == 200;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse(
      code: json['code'] ?? 500,
      message: json['message'] ?? '',
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : null,
    );
  }
}

class Pagination {
  final int page;
  final int pageSize;
  final int total;

  Pagination({
    required this.page,
    required this.pageSize,
    required this.total,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      page: json['page'] ?? 1,
      pageSize: json['page_size'] ?? 10,
      total: json['total'] ?? 0,
    );
  }
}

class PaginatedData<T> {
  final List<T> list;
  final Pagination pagination;

  PaginatedData({required this.list, required this.pagination});

  factory PaginatedData.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return PaginatedData(
      list: (json['list'] as List<dynamic>?)
              ?.map((e) => fromJsonT(e))
              .toList() ??
          [],
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
    );
  }
}
