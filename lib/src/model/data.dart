/// {@template en_logger_data}
/// # EnLoggerData
/// ## Description
/// Data that can be attached to a log message.
///
/// Use this class to attach additional contextual information to log messages,
/// such as serialized responses, file contents, or other relevant data.
///
/// ## Example:
/// ```dart
/// final data = EnLoggerData(
///   name: 'response',
///   content: jsonEncode('BE data'),
///   description: 'serialized BE response',
/// );
///
/// logger.error(
///   'API call failed',
///   data: [data],
/// );
/// ```
/// {@endtemplate}
class EnLoggerData {
  /// # Constructor
  /// ## Description
  /// Creates a new [EnLoggerData] instance.
  ///
  /// ## Parameters
  /// [name] - The name of the data. For example, if the data is a file,
  /// this would be the file name. If it's a response, it could be
  /// 'response' or 'api_response'.
  ///
  /// [content] - The encoded data content.
  /// This should be a string representation of the data,
  /// such as JSON-encoded data.
  ///
  /// [description] - A short description of the content.
  /// For example, if the data is a file,
  /// this would describe what the file contains.
  ///
  /// {@macro en_logger_data}
  const EnLoggerData({
    required this.name,
    required this.content,
    required this.description,
  });

  /// Data name.
  ///
  /// For example, if the data is a file, then it will be the file name.
  /// If it's a response, it could be 'response' or 'api_response'.
  final String name;

  /// Data description.
  ///
  /// For example, if the data is a file, then it will be a short description
  /// of the content.
  final String description;

  /// Encoded data content.
  ///
  /// This should be a string representation of the data,
  /// such as JSON-encoded data.
  final String content;
}
