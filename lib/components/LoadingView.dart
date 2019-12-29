import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';

class LoadingView extends StatefulWidget {
  final double width;
  final Color color;
  LoadingView({this.width, this.color});
  @override
  State createState() {
    return new BallPulseIndicatorState(width: this.width, color: this.color);
  }
}

class BallPulseIndicatorState extends State<LoadingView>
    with SingleTickerProviderStateMixin {
  //间距宽度除以直径的倍数
  static double spaceRatio = 0.5;
  static int duration = 800;
  static int delay = 300;
  static double scaleBegin = 0.7;
  static double scaleEnd = 1;
  Paint paint;
  double width;
  Color color;
  Size size;
  BallPulseIndicatorState({this.width, this.color});
  Animation<double> animation;
  AnimationController controller;

  @override
  void initState() {
    this.width ??= 40;
    this.color ??= Colors.black;
    _initPaint();
    _initAnimation();

    double d = this.width / (3 + spaceRatio * 2);
    this.size = Size(this.width, d);
    super.initState();
  }

  void _initPaint() {
    paint = Paint()
      ..style = PaintingStyle.fill
      ..color = this.color
      ..strokeWidth = 1;
  }

  void _initAnimation() {
    controller = AnimationController(
        duration: Duration(milliseconds: BallPulseIndicatorState.duration),
        vsync: this);
    animation = Tween<double>(begin: 0, end: 2).animate(controller)
      ..addListener(() {
        setState(() {});
      });

    controller.repeat();
  }

  @override
  Widget build(BuildContext context) {
    BallPulseIndicatorPainter painter =
        new BallPulseIndicatorPainter(this.animation);
    painter.myPaint = this.paint;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        CustomPaint(
          painter: painter,
          size: this.size,
        ),
        Padding(
          padding: EdgeInsets.only(left: 10.0),
          child: Text(
            '正在加载',
            style: TextStyle(fontSize: 20),
          ),
        )
      ],
    );
  }

  dispose() {
    controller.dispose();
    super.dispose();
  }
}

class BallPulseIndicatorPainter extends CustomPainter {
  Paint myPaint;
  Animation<double> animation;
  BallPulseIndicatorPainter(this.animation);
  @override
  void paint(Canvas canvas, Size size) {
    double d = size.height;
    double r = d / 2;
    Tween<double> tween = new Tween<double>(
        begin: BallPulseIndicatorState.scaleBegin,
        end: BallPulseIndicatorState.scaleEnd);
    //第一个圆的绘制半径
    double firstScaleValue;
    double firstTempR;
    double scaleGap = (BallPulseIndicatorState.scaleEnd -
            BallPulseIndicatorState.scaleBegin) /
        BallPulseIndicatorState.duration *
        BallPulseIndicatorState.delay;
    double secondScaleValue;
    bool firstRGrow;
    bool secondRGrow;
    if (this.animation.value > 1) {
      firstRGrow = false;
      firstScaleValue = tween.lerp(2 - this.animation.value);
      firstTempR = firstScaleValue * r;
    } else {
      firstRGrow = true;
      firstScaleValue = tween.lerp(this.animation.value);
      firstTempR = firstScaleValue * r;
    }
    if (firstRGrow) {
      //第一个圆在长大
      if (firstScaleValue > scaleGap + BallPulseIndicatorState.scaleBegin) {
        secondRGrow = true;
        secondScaleValue = firstScaleValue - scaleGap;
      } else {
        //第一个圆长大，第二个圆在缩小
        secondRGrow = false;
        secondScaleValue = scaleGap +
            BallPulseIndicatorState.scaleBegin -
            firstScaleValue +
            BallPulseIndicatorState.scaleBegin;
      }
    } else {
      //第一个圆在缩小
      if (firstScaleValue + scaleGap < BallPulseIndicatorState.scaleEnd) {
        secondRGrow = false;
        secondScaleValue = firstScaleValue + scaleGap;
      } else {
        //第一个圆缩小，第二个圆长大
        secondRGrow = true;
        secondScaleValue = BallPulseIndicatorState.scaleEnd -
            firstScaleValue +
            BallPulseIndicatorState.scaleEnd -
            scaleGap;
      }
    }

    double thirdScaleValue;
    if (secondRGrow) {
      if (secondScaleValue - scaleGap > BallPulseIndicatorState.scaleBegin) {
        thirdScaleValue = secondScaleValue - scaleGap;
      } else {
        //第二个圆长大，第三个圆缩小
        thirdScaleValue = scaleGap +
            BallPulseIndicatorState.scaleBegin * 2 -
            secondScaleValue;
      }
    } else {
      //第二个圆缩小，
      if (secondScaleValue + scaleGap < BallPulseIndicatorState.scaleEnd) {
        thirdScaleValue = secondScaleValue + scaleGap;
      } else {
        //第二个圆缩小，第三个圆增大
        thirdScaleValue =
            BallPulseIndicatorState.scaleEnd * 2 - secondScaleValue - scaleGap;
      }
    }

    double secondTempR = r * secondScaleValue;
    double thirdTempR = r * thirdScaleValue;
    //绘制第一个圆
    canvas.drawCircle(Offset(r, r), firstTempR, myPaint);
    //绘制第二个圆
    canvas.drawCircle(Offset(d + d * BallPulseIndicatorState.spaceRatio + r, r),
        secondTempR, myPaint);
    //绘制第三个圆
    canvas.drawCircle(
        Offset(d * 2 + d * BallPulseIndicatorState.spaceRatio * 2 + r, r),
        thirdTempR,
        myPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
