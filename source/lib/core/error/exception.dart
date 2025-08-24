import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import 'failure.dart';

class ServerException implements Exception {}

class DatabaseException implements Exception {
  final String message;

  DatabaseException(this.message);
}

class ErrorHandling {
  static Either<Failure, T> handleException<T>(exception) {
    if (exception is ServerException) {
      return const Left(ServerFailure('Server Failure', 500));
    } else if (exception is SocketException) {
      return const Left(ConnectionFailure('Failed to connect to the network'));
    } else if (exception is HttpException) {
      return const Left(ServerFailure('Http Exception', 500));
    } else if (exception is FormatException) {
      return const Left(ServerFailure('Format Exception', 500));
    } else if (exception is DioException) {
      // Handling DioException with fallback and proper key checks
      
      String errorMessage = 'Unknown Dio Exception';
      if (exception.response?.data != null) {
        var responseData = exception.response?.data;
        
        // Check if the message key exists
        if (responseData is Map<String, dynamic>) {
          errorMessage = responseData['message'] ?? 
                         responseData['errorCode']?.toString() ?? 
                         responseData['details']?.join(', ') ?? 
                         'Unknown Dio Exception';
        }
      } else {
        errorMessage = exception.message ?? 'Unknown Dio Exception';
      }
      if (exception.response?.statusCode == 400) {
        return Left(NotFoundException(
            errorMessage,
            exception.response?.statusCode ?? 400
        ));
      } else if (exception.response?.statusCode == 401) {
        var responseData = exception.response?.data;
        return Left(ServerFailure(
            errorMessage = responseData['message'] ?? 'Unknown Dio Exception',
            exception.response?.statusCode ?? 401
        ));
      } else {
        return Left(
          ServerFailure(
            errorMessage,
            exception.response?.statusCode ?? 500,
          ),
        );
      }
    } else {
      return Left(ServerFailure(exception.toString(), 500));
    }
  }
}

