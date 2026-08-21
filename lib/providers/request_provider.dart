import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:laroona_flutter_lib/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';

enum RequestError {
  noInternetConnection,
  serverDown,
  sessionExpired,
  unhandledServerException,
  unstableInternetConnection,
  invalidParameters,
}

class RequestProvider extends ChangeNotifier {
  final String apiBaseUrl;

  List<Request> requests = [];
  List<Request> postRequests = [];

  late StreamController<dynamic> onPostRequestSuccessStreamController;
  late Stream<dynamic> onPostRequestSuccessStream;

  DateTime? _lastErrorToastTime;
  static const Duration _errorToastDebounceThreshold = Duration(seconds: 3);

  RequestProvider({required this.apiBaseUrl}) {
    onPostRequestSuccessStreamController = StreamController<dynamic>();
    onPostRequestSuccessStream = onPostRequestSuccessStreamController.stream
        .asBroadcastStream();
  }

  Dio getDio(BuildContext context) {
    final dio = Dio(
      BaseOptions(
        baseUrl: apiBaseUrl,
        contentType: Headers.jsonContentType,
        sendTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        connectTimeout: const Duration(seconds: 10),
        validateStatus: (statusCode) {
          if (statusCode == null || statusCode > 299) {
            return false;
          }

          return true;
        },
      ),
    );
    dio.options.headers['Accept'] = Headers.jsonContentType;

    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token.isNotEmpty) {
      dio.options.headers['Authorization'] = 'Bearer $token';
    }

    return dio;
  }

  void setRequests(List<Request> requests) {
    this.requests = requests;
    notifyListeners();
  }

  void setPostRequests(List<Request> postRequests) {
    this.postRequests = postRequests;
    notifyListeners();
  }

  Future<void> fetchRequest(
    BuildContext context, {
    required String key,
    required String path,
    required int pageSize,
    required bool appendNewData,
    required bool forceFetch,
    required bool restartPage,
  }) async {
    Request? request = getRequest(key);
    request.path = path;
    request.pageSize = pageSize;
    request.appendNewData = appendNewData;

    if (restartPage) {
      request.currentPage = 0;
      request.rawData = [];
      request.data = [];
    }

    if (request.currentPage == request.lastPage) {
      return;
    }

    request.generatePath();

    await fetchRequests(context, [request], forceFetch);
  }

  Future<void> fetchRequests(
    BuildContext context,
    List<Request> requestsToFetch, [
    bool forceFetch = false,
    bool loadCachedData = true,
  ]) async {
    if (!Provider.of<AuthProvider>(context, listen: false).loggedIn) {
      return;
    }

    final dio = getDio(context);
    for (Request requestToFetch in requestsToFetch) {
      Request? request = getRequest(requestToFetch.key);
      request.path = requestToFetch.path;
      request.onSuccess = requestToFetch.onSuccess;

      if (!forceFetch && (request.isLoading || request.isDone)) {
        continue;
      }

      request.pathWithParams = requestToFetch.pathWithParams;
      if (request.pathWithParams.toString().isEmpty) {
        request.data = [];
        continue;
      }

      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        final prefs = await SharedPreferences.getInstance();
        final encodedResponseData = prefs.getString(request.key);
        if (encodedResponseData != null && encodedResponseData.isNotEmpty) {
          final responseData = jsonDecode(encodedResponseData);
          _parseResponseData(request, responseData);
          if (request.onSuccess != null) {
            request.onSuccess!(responseData);
          }
        }
        continue;
      }

      request.isLoading = true;
      notifyListeners();

      try {
        final response = await dio.get(request.pathWithParams);
        var responseData = response.data is String
            ? null
            : response.data?['data'];
        if (responseData == null) {
          if (request.onSuccess != null) {
            request.onSuccess!(null);
          }
          request.data = [];
          request.isLoading = false;
          request.isDone = true;
          notifyListeners();
          continue;
        }

        _parseResponseData(request, responseData);

        if (request.onSuccess != null) {
          request.onSuccess!(responseData);
        }

        final prefs = await SharedPreferences.getInstance();
        prefs.setString(request.key, jsonEncode(responseData));
      } on DioException catch (e) {
        final requestError = _getRequestError(e);

        if (context.mounted) {
          if (requestError == RequestError.serverDown) {
            // If Server is down, proceed as normal with cached data and no error message
            request.isLoading = false;
            request.isDone = true;
            notifyListeners();
          } else {
            _handleErrorFromResponse(context, request, e.response, e, true);
          }
        }

        if (loadCachedData) {
          final prefs = await SharedPreferences.getInstance();
          final encodedResponseData = prefs.getString(request.key);
          if (encodedResponseData != null && encodedResponseData.isNotEmpty) {
            if (request.appendNewData && request.rawData.isNotEmpty) {
              return;
            }

            final responseData = jsonDecode(encodedResponseData);
            _parseResponseData(request, responseData);
            // If server is down or unstable internet connection, call onSuccess if it exists
            // So the app can still work offline
            if (requestError == RequestError.serverDown ||
                requestError == RequestError.unstableInternetConnection) {
              if (request.onSuccess != null) {
                request.onSuccess!(responseData);
              }
            }
          }
        }
      }
    }
  }

  bool _isServerDown(DioException? responseError) {
    if (responseError == null) {
      return false;
    }

    if (responseError.error is SocketException) {
      final error = responseError.error as SocketException;
      if (error.osError?.errorCode == 7) {
        return true;
      }
    }

    // receiveTimeout means connection established but server not responding
    if (responseError.type == DioExceptionType.receiveTimeout) {
      return true;
    }

    return false;
  }

  void _parseResponseData(Request request, dynamic rawResponseData) {
    var responseData = rawResponseData;
    if (responseData is Map && responseData.containsKey('current_page')) {
      request.isPaginated = true;
      request.currentPage = responseData['current_page'];
      request.lastPage = responseData['last_page'];
      request.total = responseData['total'];
      request.clocked = responseData['clocked'];
      request.totalLive = responseData['total_live'];
      responseData = responseData['data'];
    } else if (responseData is Map && responseData.containsKey('data')) {
      request.isPaginated = false;
      request.total = responseData['total'];
      request.clocked = responseData['clocked'];
      request.totalLive = responseData['total_live'];
      responseData = responseData['data'];
      request.currentPage = 0;
      request.lastPage = 1;
    } else {
      request.isPaginated = false;
      request.currentPage = 0;
      request.lastPage = 1;
    }

    if (responseData is Map) {
      request.singleData = responseData;
    } else {
      if (request.appendNewData) {
        request.rawData.addAll(responseData);
        if (rawResponseData is Map) {
          rawResponseData['data'] = request.rawData;
        }
      } else {
        request.rawData = responseData;
      }

      request.data = request.rawData;
      request.filteredData = null;
    }

    request.isLoading = false;
    request.isDone = true;

    notifyListeners();
  }

  Request _getRequestFromRequests(List<Request> requestsParam, key) {
    var request = requestsParam.firstWhereOrNull(
      (element) => element.key == key,
    );
    if (request == null) {
      request = Request(key: key, path: '');
      requestsParam.add(request);
    }

    return request;
  }

  Request getRequest(String key) {
    return _getRequestFromRequests(requests, key);
  }

  Request getPostRequest(String key) {
    return _getRequestFromRequests(postRequests, key);
  }

  void setPostRequest(Request postRequest) {
    Request? existingPostRequest = postRequests.firstWhereOrNull(
      (element) => element.key == postRequest.key,
    );
    if (existingPostRequest == null) {
      postRequests.add(postRequest);
    } else {
      existingPostRequest.postData = postRequest.postData;
      existingPostRequest.errors = null;
      existingPostRequest.errorMessage = null;
    }

    notifyListeners();
  }

  String? getPostRequestErrorProperty(String key, String dataKey) {
    final errors = getPostRequest(key).errors;
    if (errors == null || !errors.containsKey(dataKey)) {
      return null;
    }

    if (errors[dataKey] is List) {
      return errors[dataKey][0];
    }

    return errors[dataKey];
  }

  void setPostRequestErrorProperty(String key, String dataKey, String error) {
    var errors = getPostRequest(key).errors;
    errors ??= {};
    errors[dataKey] = error;
    getPostRequest(key).errors = errors;
    notifyListeners();
  }

  void clearPostRequestErrorProperty(String key, String dataKey) {
    final errors = getPostRequest(key).errors;
    if (errors == null || !errors.containsKey(dataKey)) {
      return;
    }

    (errors as Map).remove(dataKey);
    notifyListeners();
  }

  void clearRequests() {
    requests = [];
    postRequests = [];
  }

  void submitPostRequest({
    required BuildContext context,
    required String key,
    required String path,
    bool showToast = true,
    bool showErrorToast = true,
    bool showErrorToastForAllError = false,
    Function(dynamic responseData)? onSuccess,
    Function(dynamic responseData, RequestError requestError)? onError,
    dynamic extraParameters,
  }) async {
    Request? request = getPostRequest(key);
    request.path = path;

    if (!isValid(context, key)) {
      if (onError != null) {
        onError(null, RequestError.invalidParameters);
      }
      return;
    }

    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      if (showErrorToast && context.mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.error,
          title: const Text(
            'No internet connection. Please check your internet connection and try again.',
          ),
          alignment: Alignment.topCenter,
          autoCloseDuration: const Duration(seconds: 5),
        );
      }
      if (onError != null) {
        onError(null, RequestError.noInternetConnection);
      }
      return;
    }

    if (!context.mounted) {
      return;
    }

    request.isLoading = true;
    request.errorMessage = null;
    request.errors = null;
    notifyListeners();

    final data = request.postData;

    if (extraParameters != null) {
      extraParameters.forEach((key, value) {
        data[key] = value;
      });
    }

    final dio = getDio(context);
    try {
      final response = await dio.post(request.path, data: data);

      request.isLoading = false;
      request.isDone = true;
      notifyListeners();

      final responseData = response.data['data'];
      if (request.onSuccess != null) {
        request.onSuccess!(responseData);
      }

      if (onSuccess != null) {
        onSuccess(responseData);
      }

      if (showToast && context.mounted) {
        final successMessage =
            response.data['success_message'] ?? 'Successfully saved.';
        toastification.show(
          context: context,
          type: ToastificationType.success,
          title: Text(successMessage),
          alignment: Alignment.topCenter,
          autoCloseDuration: const Duration(seconds: 5),
        );
      }

      onPostRequestSuccessStreamController.sink.add({
        'key': key,
        'responseData': responseData,
      });
    } on DioException catch (e) {
      final requestError = _getRequestError(e);

      if (context.mounted) {
        if (requestError == RequestError.serverDown) {
          // If Server is down, do not show error
          request.isLoading = false;
          request.isDone = true;
          notifyListeners();
        } else {
          _handleErrorFromResponse(
            context,
            request,
            e.response,
            e,
            false,
            showErrorToast,
            showErrorToastForAllError,
          );
        }
      }

      if (onError != null) {
        onError(e, requestError);
      }
    }
  }

  void submitDeleteRequest({
    required BuildContext context,
    required String key,
    required int id,
    required String path,
    bool showToast = true,
    bool showErrorToast = true,
    Function(dynamic responseData)? onSuccess,
    Function(dynamic responseData, RequestError requestError)? onError,
  }) async {
    final request = getPostRequest(key);
    request.path = path;
    request.isLoading = true;
    request.isDone = false;
    request.errorMessage = null;
    request.errors = null;
    notifyListeners();

    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      request.isLoading = false;
      request.isDone = true;
      notifyListeners();

      if (showErrorToast && context.mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.error,
          title: const Text(
            'No internet connection. Please check your internet connection and try again.',
          ),
          alignment: Alignment.topCenter,
          autoCloseDuration: const Duration(seconds: 5),
        );
      }
      if (onError != null) {
        onError(null, RequestError.noInternetConnection);
      }
      return;
    }

    if (!context.mounted) {
      request.isLoading = false;
      request.isDone = true;
      notifyListeners();
      return;
    }

    final dio = getDio(context);
    try {
      final response = await dio.delete(path);
      final responseData = response.data['data'];

      request.isLoading = false;
      request.isDone = true;
      notifyListeners();

      if (onSuccess != null) {
        onSuccess(responseData);
      }

      if (showToast && context.mounted) {
        final successMessage =
            response.data['success_message'] ?? 'Item deleted successfully.';
        toastification.show(
          context: context,
          type: ToastificationType.success,
          title: Text(successMessage),
          alignment: Alignment.topCenter,
          autoCloseDuration: const Duration(seconds: 5),
        );
      }
    } on DioException catch (e) {
      final requestError = _getRequestError(e);

      if (context.mounted) {
        _handleErrorFromResponse(
          context,
          request,
          e.response,
          e,
          false,
          showErrorToast,
          true,
        );
      }

      if (onError != null) {
        onError(e, requestError);
      }
    }
  }

  RequestError _getRequestError(DioException e) {
    var requestError = RequestError.unhandledServerException;
    if (_isServerDown(e)) {
      requestError = RequestError.serverDown;
    } else if (_isUnstableInterConnection(e)) {
      requestError = RequestError.unstableInternetConnection;
    } else if (e.type == DioExceptionType.badResponse) {
      requestError = RequestError.invalidParameters;
    }

    return requestError;
  }

  bool _isUnstableInterConnection(DioException exception) {
    final type = exception.type;
    return type == DioExceptionType.connectionTimeout ||
        type == DioExceptionType.connectionError ||
        type == DioExceptionType.sendTimeout;
  }

  void _handleErrorFromResponse(
    BuildContext context,
    Request request,
    dynamic response, [
    DioException? exception,
    bool forGetRequest = false,
    bool showErrorToast = true,
    bool showErrorToastForAllError = false,
  ]) {
    dynamic error = '';
    if (response == null || response.data == null || response.data is String) {
      if (exception != null && _isUnstableInterConnection(exception)) {
        if (forGetRequest) {
          error = 'Unstable internet connection. Will use cached data.';
        } else {
          error = 'Unstable internet connection. Please try again.';
        }
      } else {
        error = 'Something went wrong. Please try again.';
      }
    } else {
      if (response.data.containsKey('message')) {
        if (response.data['message'].contains("Unauthenticated")) {
          error = 'Session has expired. Please login again.';
          Provider.of<AuthProvider>(context, listen: false).logout(context);
        } else {
          error = 'Something went wrong. Please try again.';
        }
      } else {
        error = response.data['error'];
      }
    }

    request.isLoading = false;
    request.isDone = true;

    var errorMessage = '';
    if (error is Map) {
      request.errors = error;

      if (request.errors.isNotEmpty && showErrorToastForAllError) {
        errorMessage = request.errors.entries
            .map((entry) {
              if (entry.value is List) {
                return '${entry.value.join(', ')}';
              }

              return entry.value;
            })
            .join('\n');
      }
    } else {
      errorMessage = error ?? 'Something went wrong. Please try again.';
      request.errorMessage = errorMessage;
    }

    if (context.mounted &&
        errorMessage.isNotEmpty &&
        showErrorToast &&
        _shouldShowErrorToast(forGetRequest)) {
      toastification.show(
        context: context,
        type: ToastificationType.error,
        title: Text(errorMessage),
        alignment: Alignment.topCenter,
        autoCloseDuration: const Duration(seconds: 5),
      );
    }

    notifyListeners();
  }

  bool _shouldShowErrorToast(bool forGetRequest) {
    // Only debounce for GET requests, not POST requests
    if (!forGetRequest) {
      return true;
    }

    final now = DateTime.now();
    if (_lastErrorToastTime == null) {
      _lastErrorToastTime = now;
      return true;
    }

    final timeSinceLastToast = now.difference(_lastErrorToastTime!);
    if (timeSinceLastToast >= _errorToastDebounceThreshold) {
      _lastErrorToastTime = now;
      return true;
    }

    return false;
  }

  void refreshListeners() {
    notifyListeners();
  }

  bool isValid(BuildContext context, String key) {
    final requestProvider = Provider.of<RequestProvider>(
      context,
      listen: false,
    );
    final postRequest = requestProvider.getPostRequest(key);
    if (postRequest.validations.isEmpty) {
      return true;
    }

    var isValid = true;
    postRequest.errors ??= {};

    for (var validation in postRequest.validations) {
      final value = postRequest.postData[validation.dataKey];
      if (validation.isRequired &&
          (value == null ||
              (value is String && value.isEmpty) ||
              (value is List && value.isEmpty) ||
              (value is int && value == 0))) {
        postRequest.errors[validation.errorKey ?? validation.dataKey] =
            'This field is required.';
        isValid = false;
        continue;
      }

      if (validation.requiredLength != null &&
          value.length != validation.requiredLength) {
        postRequest.errors[validation.errorKey ?? validation.dataKey] =
            'This field must be ${validation.requiredLength} characters long.';
        isValid = false;
        continue;
      }

      if (validation.isDate &&
          value != null &&
          value is String &&
          value.isNotEmpty) {
        // Validate mm/dd/yyyy or yyyy-mm-dd format
        final uiDateRegex = RegExp(
          r'^(0[1-9]|1[0-2])/(0[1-9]|[12][0-9]|3[01])/\d{4}$',
        );
        final sqlDateRegex = RegExp(
          r'^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$',
        );

        if (!uiDateRegex.hasMatch(value) && !sqlDateRegex.hasMatch(value)) {
          postRequest.errors[validation.errorKey ?? validation.dataKey] =
              'Invalid date format. Use mm/dd/yyyy.';
          isValid = false;
          continue;
        }

        // Validate if it's a real date
        try {
          int month, day, year;

          if (value.contains('/')) {
            // mm/dd/yyyy format
            final parts = value.split('/');
            month = int.parse(parts[0]);
            day = int.parse(parts[1]);
            year = int.parse(parts[2]);
          } else {
            // yyyy-mm-dd format
            final parts = value.split('-');
            year = int.parse(parts[0]);
            month = int.parse(parts[1]);
            day = int.parse(parts[2]);
          }

          final date = DateTime(year, month, day);
          if (date.month != month || date.day != day || date.year != year) {
            postRequest.errors[validation.errorKey ?? validation.dataKey] =
                'Invalid date.';
            isValid = false;
            continue;
          }
        } catch (e) {
          postRequest.errors[validation.errorKey ?? validation.dataKey] =
              'Invalid date.';
          isValid = false;
          continue;
        }
      }

      if (validation.isTime &&
          value != null &&
          value is String &&
          value.isNotEmpty) {
        // Validate hh:mm:ss format (allows any two-digit numbers)
        final timeRegex = RegExp(r'^\d{2}:\d{2}:\d{2}$');

        if (!timeRegex.hasMatch(value)) {
          postRequest.errors[validation.errorKey ?? validation.dataKey] =
              'Invalid time format. Use hh:mm:ss.';
          isValid = false;
          continue;
        }

        // Validate actual time values (hours, minutes, seconds ranges)
        try {
          final parts = value.split(':');
          final hour = int.parse(parts[0]);
          final minute = int.parse(parts[1]);
          final second = int.parse(parts[2]);

          if (hour < 0 ||
              hour > 23 ||
              minute < 0 ||
              minute > 59 ||
              second < 0 ||
              second > 59) {
            postRequest.errors[validation.errorKey ?? validation.dataKey] =
                'Invalid time.';
            isValid = false;
            continue;
          }
        } catch (e) {
          postRequest.errors[validation.errorKey ?? validation.dataKey] =
              'Invalid time.';
          isValid = false;
          continue;
        }
      }
    }

    if (isValid) {
      postRequest.errors = null;
    }

    notifyListeners();
    return isValid;
  }
}

class Request {
  String key;
  String path;
  String pathWithParams = '';
  bool isLoading = false;
  bool isDone = false;

  List rawData = [];
  List data = [];
  List? filteredData;

  Map? singleData;

  Map postData = {'id': 0};

  dynamic errors;
  dynamic errorMessage;
  List<PostDataValidation> validations = [];

  Function(dynamic responseData)? onSuccess;

  bool isPaginated = false;
  bool appendNewData;
  int currentPage = 0;
  int lastPage = 1;
  int pageSize = 0;
  int? total;
  int? clocked;
  int? totalLive;

  String queryText = '';

  Request({
    required this.key,
    required this.path,
    this.pageSize = 0,
    this.appendNewData = false,
    this.onSuccess,
  }) {
    if (pageSize != 0) {
      pathWithParams = '$path?page_size=$pageSize';
    } else {
      pathWithParams = path;
    }
  }

  String? getError(String key) {
    if (errors == null || !errors.containsKey(key)) {
      return null;
    }

    return errors[key][0];
  }

  void generatePath() {
    bool alreadyHasParameter = path.contains('?');
    String delimiter = alreadyHasParameter ? '&' : '?';
    if (queryText.length >= 3) {
      pathWithParams = '$path${delimiter}query_text=$queryText';
      return;
    }

    currentPage += 1;
    if (currentPage > lastPage) {
      currentPage = lastPage;
    }

    pathWithParams = '$path${delimiter}page_size=$pageSize&page=$currentPage';
  }

  bool isForCreation() {
    return postData['id'] == 0;
  }

  String getTotal() {
    if (total == null) {
      return '-';
    }

    return total.toString();
  }
}

class PostDataValidation {
  String dataKey;
  String? errorKey;
  bool isRequired = false;
  int? requiredLength;
  bool isDate = false;
  bool isTime = false;

  PostDataValidation({
    required this.dataKey,
    this.errorKey,
    this.isRequired = false,
    this.requiredLength,
    this.isDate = false,
    this.isTime = false,
  });
}
