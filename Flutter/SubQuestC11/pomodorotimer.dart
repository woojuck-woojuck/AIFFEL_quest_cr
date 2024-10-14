import 'dart:async';
import 'dart:io';

class PomodoroTimer {
  int workDuration; // 작업 시간 (초 단위)
  int shortBreakDuration; // 짧은 휴식 시간 (초 단위)
  int longBreakDuration; // 긴 휴식 시간 (초 단위)
  int cycleCount = 0;
  Timer? countdownTimer;
  Stream<List<int>>? inputStream;

  PomodoroTimer({
    this.workDuration = 25 * 60,
    this.shortBreakDuration = 5 * 60,
    this.longBreakDuration = 15 * 60,
  }) {
    inputStream = stdin.asBroadcastStream();
  }

  void startPomodoro() {
    print('q를 입력하면 프로그램이 종료됩니다.');
    _startCycle();
    _listenForStop();
  }

  void _startCycle() {
    if (cycleCount < 4) {
      if (cycleCount == 3) {
        print('Cycle ${cycleCount + 1}: Working for ${workDuration / 60} minutes');
        _startCountdown(workDuration, () {
          print('Cycle ${cycleCount + 1}: Long break for ${longBreakDuration / 60} minutes');
          _startCountdown(longBreakDuration, () {
            cycleCount++;
            if (cycleCount < 4) {
              _startCycle();
            } else {
              print('Pomodoro complete!');
              _askToRestart();
            }
          });
        });
      } else {
        print('Cycle ${cycleCount + 1}: Working for ${workDuration / 60} minutes');
        _startCountdown(workDuration, () {
          print('Cycle ${cycleCount + 1}: Short break for ${shortBreakDuration / 60} minutes');
          _startCountdown(shortBreakDuration, () {
            cycleCount++;
            _startCycle();
          });
        });
      }
    }
  }

  void _startCountdown(int seconds, void Function() callback) {
    int remainingSeconds = seconds;
    countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      int minutes = remainingSeconds ~/ 60;
      int secs = remainingSeconds % 60;
      String formattedTime = '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
      print(formattedTime);
      remainingSeconds--;

      if (remainingSeconds < 0) {
        timer.cancel();
        callback();
      }
    });
  }

  void _listenForStop() {
    inputStream?.listen((data) {
      String input = String.fromCharCodes(data).trim();
      if (input.toLowerCase() == 'q') {
        print('시간이 멈춥니다.');
        _stopTimers();
        print('Pomodoro stopped.');
        exit(0);
      }
    });
  }

  void _askToRestart() {
    print('다시 시작하겠습니까? (Y/N)');
    inputStream?.listen((data) {
      String input = String.fromCharCodes(data).trim();
      if (input.toLowerCase() == 'y') {
        cycleCount = 0;
        _startCycle();
      } else if (input.toLowerCase() == 'n') {
        print('Pomodoro 종료.');
        exit(0);
      }
    });
  }

  void _stopTimers() {
    countdownTimer?.cancel();
  }
}

void main() {
  PomodoroTimer timer = PomodoroTimer();
  timer.startPomodoro();
}
