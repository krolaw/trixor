import 'dart:math' as math;

import 'package:flutter/material.dart';

var rnd = math.Random();

class Card {
  final int id;
  final List<int> attrs;
  bool selected = false;

  Card._fromAttrs(this.attrs)
      : id = attrs.reversed.fold<int>(0, (e, i) => e * 3 + i);
  Card(this.id, int depth)
      : attrs = List<int>.generate(depth, (i) => (id ~/ math.pow(3, i)) % 3);

  Card match(Card c) => Card._fromAttrs(
      List<int>.generate(attrs.length, (i) => (6 - attrs[i] - c.attrs[i]) % 3));

  /*bool isMatch(Card a, Card b) {
    for (int i = 0; i < attrs.length; i++)
      if (((6 - attrs[i] - a.attrs[i]) % 3) != b.attrs[i]) return false;
    return true;
  }*/

  Sum sum(List<Card> cards) {
    final s = List<int>.filled(attrs.length, 0);
    cards.forEach((c) {
      if (c.selected) return;
      for (int i = 0; i < attrs.length; i++) if (attrs[i] == c.attrs[i]) s[i]++;
    });
    return Sum(
        this,
        s
          ..sort()
          ..reversed);
  }

  String toString() => "$id " + attrs.toString();

  get hashCode => id;
  bool operator ==(Object c) => c is Card && c.id == id;
}

class Sum {
  final Card card;
  final List<int> freq;

  Sum(this.card, this.freq);

  int compare(Sum s, int pref) {
    for (int i = 0; i < freq.length; i++) {
      if (s.freq[i] < pref && freq[i] < pref) continue;
      if (s.freq[i] != freq[i]) return freq[i] < s.freq[i] ? -1 : 1;
    }
    return 0;
  }
}

class Board {
  final int count, depth, prefMax;
  final List<Card> remaining, used;

  Board(this.count, this.depth)
      : prefMax = count ~/ 3,
        remaining = List<Card>.generate(
            math.pow(3, depth) as int, (i) => Card(i, depth)),
        used = <Card>[] {
    for (var i = 0; i < count - 1; i++) {
      final c = _findNonMatchingCard();
      used.add(c);
      if (!remaining.remove(c)) print("Did not remove1 $c");
    }
    final c = _findMatchingCard();
    used.add(c);
    if (!remaining.remove(c)) print("Did not remove2 $c");
  }

  Card _findNonMatchingCard() => (remaining
          .where((c) {
            for (int i = 0; i < used.length - 1; i++)
              for (int j = i + 1; j < used.length; j++)
                if (c.match(used[i]) == used[j]) return false;
            return true;
          })
          .map((c) => c.sum(used))
          .toList()
            ..shuffle()
            ..sort((a, b) => a.compare(b, prefMax)))
      .first
      .card;

  Card _findMatchingCard() {
    final possibles = <Card, int>{};
    for (int i = 0; i < used.length - 1; i++)
      for (int j = i + 1; j < used.length; j++) {
        final c = used[i].match(used[j]);
        possibles[c] = possibles.putIfAbsent(c, () => 0) + 1;
      }
    return ((possibles..removeWhere((key, value) => value > 1))
            .keys
            .map((c) => c.sum(used))
            .toList()
              ..shuffle()
              ..sort((a, b) => a.compare(b, prefMax)))
        .first
        .card;
  }

//List<int> genCards(int count, int depth) {}

}
