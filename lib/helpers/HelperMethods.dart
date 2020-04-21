extension DynamicExtensions on dynamic {
  List<dynamic> unwrapList() {
    List<dynamic> allItems = new List();

    if (this is Iterable) {
      for (var item in this) {
        allItems.addAll(item.unwrapList());
      }
    } else {
      allItems.add(this);
    }
    return allItems;
  }
}

extension DynamicListExtension on List<dynamic> {
  List<List<dynamic>> splitIn(int chunks) {
    if (this.isEmpty) return this;
    List<List<dynamic>> superlist = new List();
    for (var i = 0; i < this.length; i += chunks) {
      superlist.add(this.sublist(i, i + chunks));
    }
    return superlist;
  }
}
