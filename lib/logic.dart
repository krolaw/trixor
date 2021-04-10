import 'dart:math' as math;

class Card {
  final int id;
  final List<int> attrs;

  Card.fromAttrs(this.attrs)
      : id = attrs.reversed.fold<int>(0, (e, i) => e * 3 + i);
  Card(this.id, int depth)
      : attrs = List<int>.generate(depth, (i) => (id ~/ math.pow(3, i)) % 3);

  Card match(Card c) => Card.fromAttrs(
      List<int>.generate(attrs.length, (i) => (6 - attrs[i] - c.attrs[i]) % 3));

  Sum sum(List<Card> cards) {
    final s = List<int>.filled(attrs.length, 0);
    cards.forEach((c) {
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
  final List<Card> used;

  Board(this.count, this.depth)
      : prefMax = math.max(3, count ~/ 3),
        used = <Card>[] {
    for (var i = 0; i < 20; i++) {
      try {
        for (var i = 0; i < count - 1; i++)
          used.add(_findNonMatchingCard(used));
        used.add(_findMatchingCard(used));
        used.shuffle();
        return;
      } catch (e) {
        used.clear();
      }
    }
    throw ("Unable to setup board");
  }

  List<Card> select(List<int> positions) {
    final cards = positions.map((p) => used[p]).toList();
    if (cards[0].match(cards[1]) != cards[2]) return [];
    final mUsed = used.toList()..removeWhere((c) => cards.contains(c));
    assert(mUsed.length == used.length - 3);
    for (var i = 0; i < 20; i++) {
      try {
        mUsed.add(_findNonMatchingCard(mUsed, exclude: cards));
        assert(mUsed.length == used.length - 2);
        mUsed.add(_findMatchingCard(mUsed));
        mUsed.add(_findNonMatchingCard(mUsed));
        return mUsed.sublist(mUsed.length - 3)..shuffle();
      } catch (e) {}
    }
    throw ("Unable to update board");
  }

  @override
  String toString() => used.toString();

  void replace(List<Card> replacements, List<int> positions) {
    assert(replacements.length == 3);
    for (var i = 0; i < replacements.length; i++)
      used[positions[i]] = replacements[i];
  }

  Card _findNonMatchingCard(List<Card> tUsed, {exclude = const <Card>[]}) =>
      (List<Card>.generate(math.pow(3, depth) as int, (i) => Card(i, depth))
              .where((c) {
                if (tUsed.contains(c) || exclude.contains(c)) return false;
                for (int i = 0; i < tUsed.length - 1; i++) {
                  for (int j = i + 1; j < tUsed.length; j++)
                    if (c.match(tUsed[i]) == tUsed[j]) return false;
                }
                return true;
              })
              .map((c) => c.sum(tUsed))
              .toList()
                ..shuffle()
                ..sort((a, b) => a.compare(b, prefMax)))
          .first
          .card;

  Card _findMatchingCard(List<Card> tUsed) {
    final possibles = <Card, int>{};
    for (int i = 0; i < tUsed.length - 1; i++) {
      for (int j = i + 1; j < tUsed.length; j++) {
        final c = tUsed[i].match(tUsed[j]);
        possibles[c] = (possibles[c] ?? 0) + 1;
      }
    }
    return ((possibles..removeWhere((key, value) => value > 1))
            .keys
            .map((c) => c.sum(tUsed))
            .toList()
              ..shuffle()
              ..sort((a, b) => a.compare(b, prefMax)))
        .first
        .card;
  }
}
