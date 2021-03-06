part of dartcoin.core;

class AlertMessage extends Message {
  //TODO implement
  
  Uint8List _message;
  Uint8List _signature;
  
  int version;
  int relayUntil;
  int expiration;
  int id;
  int cancel;
  Set<int> setCancel;
  int minVer;
  int maxVer;
  Set<String> setSubVer;
  int priority;
  String comment;
  String statusBar;
  String reversed;
  
  AlertMessage(Uint8List message, Uint8List signature) : super("alert") {
    this._message = message;
    this._signature = signature;
  }

  factory AlertMessage.deserialize(Uint8List bytes, {int length, bool lazy, NetworkParameters params, int protocolVersion}) => 
          new BitcoinSerialization.deserialize(new AlertMessage(null, null), bytes, length: length, lazy: lazy, params: params, protocolVersion: protocolVersion);
  
  Uint8List get message {
    _needInstance();
    if(_message == null)
      _message = _constructMessage();
    return _message;
  }
  
  Uint8List get signature {
    _needInstance();
    //TODO implement signing. (only necessary if we suppose holders of the alert key are going to use dartcoin)
    return _signature;
  }
  
  int _deserialize(Uint8List bytes) {
    //TODO
  }
  
  Uint8List _constructMessage() {
    List<int> result = new List<int>();
    result.addAll(Utils.uintToBytesLE(version, 4));
    result.addAll(Utils.uintToBytesLE(relayUntil, 8));
    result.addAll(Utils.uintToBytesLE(expiration, 8));
    result.addAll(Utils.uintToBytesLE(id, 4));
    result.addAll(Utils.uintToBytesLE(cancel, 4));
    //TODO how to encode the sets?
    result.addAll(Utils.uintToBytesLE(minVer, 4));
    result.addAll(Utils.uintToBytesLE(maxVer, 4));
    //another set
    result.addAll(Utils.uintToBytesLE(priority, 4));
    result.addAll(new VarStr(comment).serialize());
    result.addAll(new VarStr(statusBar).serialize());
    result.addAll(new VarStr(reversed).serialize());
    return new Uint8List.fromList(result);
  }
  
  Uint8List _serialize_payload() {
    List<int> result = new List<int>();
    result.addAll(message);
    result.addAll(signature);
    return new Uint8List.fromList(result);
  }
}