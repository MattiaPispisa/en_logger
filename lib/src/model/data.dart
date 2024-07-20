/// Data that can be attached to a log message
class EnLoggerData {
  /// Data that can be attached to a log message
  const EnLoggerData({
    required this.name,
    required this.content,
    required this.description,
  });

  /// data name.
  /// For example, if the data is a file, then it will be the file name.
  final String name;

  /// data description.
  /// For example, if the data is a file, then it will be a short description
  /// of the content.
  final String description;

  /// encoded data content
  final String content;
}
