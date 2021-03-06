part of dartcoin.core;

class TransactionOutPoint extends Object with BitcoinSerialization {
  
  static const int SERIALIZATION_LENGTH = 36;
  
  Sha256Hash _txid;
  int _index;
  
  Transaction _tx;
  
  TransactionOutPoint({ Transaction transaction, 
                        int index,
                        Sha256Hash txid,
                        NetworkParameters params: NetworkParameters.MAIN_NET}) {
    if(transaction != null)
      txid = transaction.hash;
    _index = index;
    _txid = txid;
    _tx = transaction;
    this.params = params;
  }
  
  factory TransactionOutPoint.deserialize(Uint8List bytes, {bool lazy, NetworkParameters params}) =>
      new BitcoinSerialization.deserialize(new TransactionOutPoint(), bytes, length: 36, lazy: lazy, params: params);
  
  Sha256Hash get txid {
    _needInstance();
    return _txid;
  }
  
  int get index {
    _needInstance();
    return _index;
  }
  
  /**
   * Can be `null` when this object has been created by deserialization.
   */
  Transaction get transaction {
    return _tx;
  }
  
  TransactionOutput get connectedOutput {
    if(_tx == null) return null;
    return _tx.outputs[index];
  }
  
  @override
  operator ==(TransactionOutPoint other) {
    if(!(other is TransactionOutPoint)) return false;
    return txid == other.txid &&
        index == other.index &&
        (transaction == null || other.transaction == null || transaction == other.transaction);
  }
  
  //TODO hashcode?
  
  Uint8List _serialize() {
    List<int> result = new List()
      ..addAll(txid.bytes)
      ..addAll(Utils.uintToBytesBE(index, 4));
    return new Uint8List.fromList(result);
  }
  
  int _deserialize(Uint8List bytes) {
    _txid = new Sha256Hash(bytes.sublist(0, 32));
    _index = Utils.bytesToUintBE(bytes.sublist(32), 4);
    return SERIALIZATION_LENGTH;
  }
  
  int _lazySerializationLength(Uint8List bytes) => SERIALIZATION_LENGTH;
}