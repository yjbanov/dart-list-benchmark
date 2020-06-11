// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// This benchmark measures the performance of populating [List].
///
/// ## Method
///
/// Populate lists with 2^[N] objects using the following methods:
///
/// * Spread element using a `for` loop into a list literal.
/// * Use [List.generate].
/// * Use use a fixed-sized `List(int)` constructor (not available in NNBD SDK).
/// * Start with empty `[]` and use [List.add] to add elements.
/// * Use [List.filled] to create a fixed-sized list containing placeholder values,
///   then populate the list using [List.add].
///
/// ## Variations
///
/// The benchmark populates 32768 elements, but breaks down the lists into
/// different sizes, as follows:
///
/// * 32768 lists of size 1
/// * 16384 lists of size 2
/// * 8192  lists of size 4
/// * 4096  lists of size 8
/// * 2048  lists of size 16
/// * 1024  lists of size 32
/// * 512   lists of size 64
/// * 256   lists of size 128
/// * 128   lists of size 256
/// * 64    lists of size 512
/// * 32    lists of size 1024
import 'dart:math' as math;

const N = 15;

int listSize = -1;
int listCount = -1;
List<List<Foo>> lists;

class Foo {
  const Foo({this.x, this.y});

  final int x;
  final int y;

  toString() => '($x, $y)';
}

void runElement() {
  for (int i = 0; i < listCount; i++) {
    lists[i] = <Foo>[
      for (int i = 0; i < listSize; i++)
        Foo(x: i, y: i + 1)
    ];
  }
}

void runGenerateWithFilled() {
  for (int i = 0; i < listCount; i++) {
    lists[i] = List<Foo>.generate(listSize, fill);
  }
}


void runPreallocate() {
  for (int i = 0; i < listCount; i++) {
    var list = List<Foo>(listSize);
    for (int i = 0; i < listSize; i++)
      list[i] = Foo(x: i, y: i + 1);
    lists[i] = list;
  }
}

void runAdd() {
  for (int i = 0; i < listCount; i++) {
    var list = <Foo>[];
    for (int i = 0; i < listSize; i++)
      list.add(Foo(x: i, y: i + 1));
    lists[i] = list;
  }
}

const Foo _placeholder = Foo(x: 0, y: 0);

void runFill() {
  for (int i = 0; i < listCount; i++) {
    var list = List<Foo>.filled(listSize, _placeholder);
    for (int i = 0; i < listSize; i++)
      list[i] = Foo(x: i, y: i + 1);
    lists[i] = list;
  }
}

Foo fill(int value) {
  return Foo(x: value, y: value + 1);
}

void main() {
  // Run the benchmark twice. Use the first run as warm-up.
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

    print(run == 0 ? 'Warm-up run:' : 'Measured run:');
    print(buf);
    print('for element\t${elements.map((e) => e.toStringAsFixed(2)).join('\t')}');
    print('List.generate\t${generateWithFilleds.map((e) => e.toStringAsFixed(2)).join('\t')}');
    print('preallocate\t${preallocates.map((e) => e.toStringAsFixed(2)).join('\t')}');
    print('List.add\t${adds.map((e) => e.toStringAsFixed(2)).join('\t')}');
    print('List.fill\t${fills.map((e) => e.toStringAsFixed(2)).join('\t')}');
  }
}
