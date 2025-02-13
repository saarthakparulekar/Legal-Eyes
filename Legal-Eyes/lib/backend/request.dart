import 'package:http/http.dart';

Future getData(url) async{
  Response response = await get(Uri.parse(url));
  return response.body;
}

Future putData(url,header,body) async{
  Response response = await post(Uri.parse(url),headers: header ,body: body);
  return response;
}