

import 'package:dio/dio.dart';
import 'package:get_images/model/photo_model.dart';
import 'package:get_images/networking/api.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class Repository{
  static Dio get _dio{
    return Dio(
      BaseOptions(
      baseUrl: ApiRoutes.url,
        headers: {
        '${Headers.contentTypeHeader}':'application/json',
        },
      ),
    )..interceptors.addAll([
    PrettyDioLogger(requestBody:true),
    ]);
  }

  static Future<List<Results?>> getPic(int pageNumber ,String query ,int limit)async {
      try{
        Map<String, String> data = {};
        data['page'] = pageNumber.toString();
        data['query']= query.toString();
        data['per_page']=limit.toString();
        Response response =await _dio.get(ApiRoutes.url2,queryParameters: data);
        if (response.statusCode==200) {
          List<Results> photoResponse = [];
          for(int i=0; i<response.data["results"].length; i++){
            Results result =  Results.fromJson(response.data["results"][i]);
            photoResponse.add(result);
          }
          return photoResponse;
        }
      }on DioError catch(e){
        if (e.response!=null) {
          print("Dio Error");
          print("Status${e.response!.statusCode}");
          print("Data${e.response!.data}");
          print('HEADERS: ${e.response?.headers}');
        }  else{
          print('Error sending request!');
          print(e.message);
        }
        print(e);
      }
      return <Results>[];
  }
  }
