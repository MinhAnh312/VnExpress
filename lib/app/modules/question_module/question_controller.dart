import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:khoot/app/const/const.dart';
import 'package:khoot/app/data/model/question.dart';
import 'package:khoot/app/data/model/user_join.dart';
import 'package:khoot/app/data/repository/question_repository.dart';
import 'package:get/get.dart';
import 'package:khoot/app/modules/enterroom_module/enterroom_controller.dart';
import 'package:khoot/app/modules/result_module/result_page.dart';

class QuestionController extends GetxController {
  final QuestionRepository repository;

  QuestionController({this.repository});

  Timer _timer;
  RxInt start = 20.obs;
  RxInt totalQuestion = 5.obs;
  RxInt questionIndex = 1.obs;
  RxInt result = 0.obs;

  String roomId;

  Query query =
      FirebaseFirestore.instance.collection(Const.QUESTION_COLLECTION);

  Query roomQuery =
      FirebaseFirestore.instance.collection(Const.ROOM_COLLECTION);

  RxList<Question> listQuestion = <Question>[].obs;
  Rx<Question> question = Question().obs;

  RxList<String> choose = <String>[].obs;
  RxInt numberOfQuestion = 0.obs;

  RxString answer = "2".obs;
  RxInt indexChoose;
  RxBool isTrue;


  Future<void> getListQuestion() async {
    QuerySnapshot snapshot =
        await roomQuery.where("room_key", whereIn: [roomId]).get();
    var room = RoomInfo.fromJson(snapshot.docs.first.data());
    totalQuestion = room.totalQuestion.obs;
    questionIndex = room.indexQuestion.obs;
    QuerySnapshot querySnapshot = await query.get();
    for (int i = 0; i < querySnapshot.docChanges.length; i++) {
      listQuestion
          .add(Question.fromJson(querySnapshot.docChanges[i].doc.data()));
    }
  }

  void getQuestion() {
    start = 20.obs;
    indexChoose = 99.obs;
    isTrue = false.obs;
    numberOfQuestion.value = Random().nextInt(listQuestion.length);
    question.value = listQuestion[numberOfQuestion.value];
    choose.clear();
    choose.add(question.value.answer);
    choose.add(question.value.wrongAnswer1);
    choose.add(question.value.wrongAnswer2);
    choose.add(question.value.wrongAnswer3);
    answer.value = question.value.answer;
    shuffle(choose);
    listQuestion.remove(question.value);
    startTimer();
  }

  @override
  Future<void> onInit() async {
    // TODO: implement onInit
    EnterRoomController controller = Get.find();
    roomId = controller.roomId;
    await getListQuestion();
    getQuestion();
    super.onInit();
  }

  void resetQuest() {
    // questionIndex.value++;
    // if (questionIndex.value > totalQuestion.value) {
    //   stop();
    // } else {
    //   getQuestion();
    // }
    if (questionIndex.value < totalQuestion.value) {
      questionIndex++;
      getQuestion();
    } else
      stop();
  }

  List shuffle(List items) {
    var random = new Random();
    for (var i = items.length - 1; i > 0; i--) {
      var n = random.nextInt(i + 1);
      var temp = items[i];
      items[i] = items[n];
      items[n] = temp;
    }
    return items;
  }

  @override
  void onClose() {
    // TODO: implement onClose
    _timer.cancel();
    super.onClose();
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (start.value == 0) {
          timer.cancel();
          isShowResult();
        } else {
          start.value--;
        }
      },
    );
  }

  void chooseAnswer(int index) {
    indexChoose.value = index;
    start.value = 0;
     _timer.cancel();
    isShowResult();
  }

  void isShowResult() {
    if (start.value == 0) {
      if (choose.indexOf(answer.value) == indexChoose.value) {
        isTrue.value = true;
        result++;
      } else
        isTrue.value = false;
      new Timer(new Duration(milliseconds: 2000), () async {
        //resetQuest();
      });
    }
  }

  void stop() {
    Get.to(ResultPage(result.value));
  }
}