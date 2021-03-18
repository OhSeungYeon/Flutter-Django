import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:quiz_django_app/model/model_quiz.dart';
import 'package:quiz_django_app/screen/screen_result.dart';
import 'package:quiz_django_app/widget/widget_candidate.dart';

class QuizScreen extends StatefulWidget {
  List<Quiz> quizs;
  QuizScreen({this.quizs});
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  //각 퀴즈별 사용자의 정답을 담아 놓는 리스트
  List<int> _answers = [-1, -1, -1];
  //퀴즈 하나에 대하여 각 선택지가 선택되었는지를 bool 형태로 기록하는 리스트
  List<bool> _answerState = [false, false, false, false];
  // 현재 어떤 문제를 보고 있는지에 대한 리스트
  int _currentIndex = 0;
  SwiperController _controller = SwiperController();

  @override
  Widget build(BuildContext context) {
    Size scrrenSize = MediaQuery.of(context).size;
    double width = scrrenSize.width;
    double height = scrrenSize.height;
    return SafeArea(
        child: Scaffold(
          backgroundColor: Colors.deepPurple,
          body: Center(
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.deepPurple),
                ),
                width: width * 0.85,
                height: height * 0.85,
                child: Swiper(
                  controller: _controller,
                  physics: NeverScrollableScrollPhysics(),
                  loop: false,
                  itemCount: widget.quizs.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _buildQuizCard(widget.quizs[index], width, height);
                  }
                ),
              ),
          ),
        ),
    );
  }

  Widget _buildQuizCard(Quiz quiz, double width, double height) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(
                0,
                width*0.024,
                0,
                width*0.024
            ),
            child: Text(
              'Q' + (_currentIndex + 1).toString() + '.',
              style: TextStyle(
                fontSize: width * 0.06,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            width: width * 0.8,
            padding: EdgeInsets.only(top: width * 0.01),
            child: AutoSizeText(
              quiz.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(
                fontSize: width * 0.048,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Container(),
          ),
          Column(
            children: _buildCandidates(width, quiz),
          ),
          Container(
            padding: EdgeInsets.all(width * 0.1),
            child: Center(
              child : ButtonTheme(
                minWidth: width * 0.5,
                height: height * 0.05,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),

                //현재 인덱스가 마지막 퀴즈를 가리킨다면 결과보기, 혹은 다음문제가 나오도록 함.
                child: RaisedButton(child: _currentIndex == widget.quizs.length-1
                    ? Text('결과보기')
                    : Text('다음문제'),
                  textColor: Colors.white,
                  color: Colors.deepPurple,
                  // _answer가 -1 이라는 것은 아직 정답체크가 되지 않은 초기 상태라는 것임.
                  onPressed: _answers[_currentIndex] == -1
                      ? null
                      : () {
                        if(_currentIndex == widget.quizs.length-1){
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ResultScreen(
                                      answers: _answers,
                                      quizs: widget.quizs)));
                        }
                        else {
                          _answerState = [false, false, false, false];
                          _currentIndex += 1;
                          _controller.next();
                        }
                  },
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  List<Widget> _buildCandidates(double width, Quiz quiz) {
    List<Widget> _children = [];
    for(int i=0; i<4; i++) {
      _children.add(
          CandWidget(
              index: i,
              text: quiz.candidates[i],
              width: width,
              answerState: _answerState[i],
              tap: () {
                setState(() {
                  for(int j=0; j<4; j++) {
                    if(j==i) {
                      _answerState[j] = true;
                      _answers[_currentIndex] = j;
                    } else {
                      _answerState[j] = false;
                    }
                  }
                });
              },
          ),
      );
      _children.add(
        Padding(
          padding: EdgeInsets.all(width * 0.024),
        ),
      );
    }
    return _children;
  }
}