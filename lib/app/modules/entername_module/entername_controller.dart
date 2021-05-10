import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:khoot/app/const/const.dart';
import 'package:khoot/app/data/model/user_join.dart';
import 'package:khoot/app/data/repository/entername_repository.dart';
import 'package:khoot/app/modules/enterroom_module/enterroom_controller.dart';
import 'package:khoot/app/modules/question_module/question_page.dart';

class EnterNameController extends GetxController {
  final EnterNameRepository repository;

  EnterNameController({this.repository});

  String roomId;
  bool isJoined = false;

  var document;

  @override
  void onInit() async {
    EnterRoomController controller = Get.find();
    roomId = controller.roomId;
    document = FirebaseFirestore.instance
        .collection(Const.ROOM_COLLECTION)
        .doc(roomId);
    // TODO: implement onInit
    super.onInit();
  }

  Future<bool> joinRoom(String name) async {
    var snapshot = await document.get();
    if (snapshot.data().containsKey("user_join")) {
      var list = snapshot.get("user_join") as List;
      List<UserJoin> listUser = list.map((e) => UserJoin.fromJson(e)).toList();
      bool isExistName =
          listUser.indexWhere((element) => element.name == name) >= 0;
      if (!isExistName) {
        joinRoomWriteDB(name);
      } else {
        isJoined = false;
      }
    } else {
      joinRoomWriteDB(name);
    }
    return isJoined;
  }

  void joinRoomWriteDB(String name) {
    document.set({
      "user_join": FieldValue.arrayUnion([
        {"name": name, "score": 0}
      ])
    }, SetOptions(merge: true));
    Get.to(QuestionPage());
    isJoined = true;
  }
}