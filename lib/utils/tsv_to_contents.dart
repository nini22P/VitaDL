import 'package:csv/csv.dart';
import 'package:vita_dl/models/content.dart';

Future<List<Content>> tsvToContents(String content, ContentType type) async {
  String processedContent =
      content.replaceAll('\t', ',').replaceAll("'", '').replaceAll('"', '');
  List<List<dynamic>> data =
      const CsvToListConverter().convert(processedContent);
  List<Content> contents = [];
  if (data.isNotEmpty) {
    List<String> headers =
        List<String>.from(data[0].map((item) => item.toString()));
    contents = data.sublist(1).map((row) {
      Map<String, dynamic> rowMap = {};
      rowMap['Type'] = type;
      for (int i = 0; i < headers.length; i++) {
        if (i < row.length) {
          rowMap[headers[i]] = row[i].toString();
        } else {
          rowMap[headers[i]] = '';
        }
      }
      return Content.convert(rowMap).copyWith(type: type);
    }).toList();
  }
  return contents;
}
