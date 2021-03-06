part of dartcoin.core;

abstract class InventoryItemContainerMessage extends Message {
  
  List<InventoryItem> _items;
  
  InventoryItemContainerMessage(String command, List<InventoryItem> items) : super(command) {
    if(items.length > 50000) {
      throw new Exception("Maximum 50000 inventory items");
    }
    _items = items;
  }
  
  List<InventoryItem> get items {
    _needInstance();
    return new UnmodifiableListView(_items);
  }
  
  int _deserialize(Uint8List bytes) {
    int offset = Message._preparePayloadSerialization(bytes, this);
    VarInt nbItems = new VarInt.deserialize(bytes.sublist(offset));
    offset += nbItems.size;
    _items = new List<InventoryItem>();
    for(int i = 0 ; i < nbItems.value ; i++) {
      _items.add(new InventoryItem.deserialize(
          bytes.sublist(offset, offset + InventoryItem.SERIALIZATION_LENGTH), lazy: false));
      offset += InventoryItem.SERIALIZATION_LENGTH;
    }
    return offset;
  }
  
  Uint8List _serialize_payload() {
    List<int> result = new List<int>()
      ..addAll(new VarInt(items.length).serialize());
    for(InventoryItem item in items) {
      result.addAll(item.serialize());
    }
    return new Uint8List.fromList(result);
  }
}