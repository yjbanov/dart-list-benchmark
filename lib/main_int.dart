// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// [int] variant of [main.dart].
import 'dart:math' as math;

const N = 15;

int listSize = -1;
int listCount = -1;
List<List<int>> lists;

void runElement() {
  for (int i = 0; i < listCount; i++) {
    lists[i] = <int>[
      for (int i = 0; i < listSize; i++)
        i
    ];
  }
}

void runGenerateWithFilled() {
  for (int i = 0; i < listCount; i++) {
    lists[i] = List<int>.generate(listSize, fill);
  }
}


void runPreallocate() {
  for (int i = 0; i < listCount; i++) {
    var list = List<int>(listSize);
    for (int i = 0; i < listSize; i++)
      list[i] = i;
    lists[i] = list;
  }
}

void runAdd() {
  for (int i = 0; i < listCount; i++) {
    var list = <int>[];
    for (int i = 0; i < listSize; i++)
      list.add(i);
    lists[i] = list;
  }
}

const int _placeholder = -1;

void runFill() {
  for (int i = 0; i < listCount; i++) {
    var list = List<int>.filled(listSize, _placeholder);
    for (int i = 0; i < listSize; i++)
      list[i] = i;
    lists[i] = list;
  }
}

int fill(int value) {
  return value;
}

void main() {
  for (int run = 0; run < 2; run++) {
    List<int> elements = <int>[];
    List<int> generateWithFilleds = <int>[];
    List<int> preallocates = <int>[];
    List<int> adds = <int>[];
    List<int> fills = <int>[];

    final StringBuffer buf = StringBuffer('\t');
    for (int i = 0; i <= 10; i++) {
      listSize = math.pow(2, i);
      listCount = math.pow(2, N - i);
      print('${listSize * listCount} = $listCount (lists) x $listSize (elements per list)');
      buf.write('($listCount x $listSize)\t');
      var sw = Stopwatch();
      int element = 0;
      int generateWithFilled = 0;
      int preallocate = 0;
      int add = 0;
      int fill = 0;

      for (int i = 0; i < 40; i++) {
        lists = List(listCount);
        sw.reset();
        sw.start();
        runElement();
        sw.stop();
        element += sw.elapsedMicroseconds;

        sw.reset();
        sw.start();
        runGenerateWithFilled();
        sw.stop();
        generateWithFilled += sw.elapsedMicroseconds;

        sw.reset();
        sw.start();
        runPreallocate();
        sw.stop();
        preallocate += sw.elapsedMicroseconds;

        sw.reset();
        sw.start();
        runAdd();
        sw.stop();
        add += sw.elapsedMicroseconds;

        sw.reset();
        sw.start();
        runFill();
        sw.stop();
        fill += sw.elapsedMicroseconds;
      }
      elements.add(element);
      generateWithFilleds.add(generateWithFilled);
      preallocates.add(preallocate);
      adds.add(add);
      fills.add(fill);
    }

    if (run != 0) {
      print(buf);
      print('for element\t${elements.map((e) => e.toStringAsFixed(2)).join('\t')}');
      print('List.generate\t${generateWithFilleds.map((e) => e.toStringAsFixed(2)).join('\t')}');
      print('preallocate\t${preallocates.map((e) => e.toStringAsFixed(2)).join('\t')}');
      print('List.add\t${adds.map((e) => e.toStringAsFixed(2)).join('\t')}');
      print('List.fill\t${fills.map((e) => e.toStringAsFixed(2)).join('\t')}');
    }
  }
}
