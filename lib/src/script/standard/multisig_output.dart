part of dartcoin.core;

class MultiSigOutputScript extends Script {

  /**
   * Create a new multi-signature output script that requires at least <threshold> of the given keys to sign using
   * OP_CHECKMULTISIG.
   * 
   * Standard multisig outputs have max 3 keys, but it is possible to add up to 16 keys.
   * 
   * If [encoded] is set to false, the script will be built using chunks. This improves
   * performance when the script is intended for execution.
   */
  factory MultiSigOutputScript(int threshold, List<KeyPair> pubkeys, [bool encoded = true]) {
    if(threshold <= 0 || threshold > pubkeys.length) throw new ScriptException("Invalid threshold value.");
    if(pubkeys.length > 16) throw new ScriptException("Maximum 16 public keys.");
    
    ScriptBuilder builder = new ScriptBuilder(encoded)
      .smallNum(threshold);
    pubkeys.forEach((pk) => builder.data(pk.publicKey));
    builder.smallNum(pubkeys.length)
      .op(ScriptOpCodes.OP_CHECKMULTISIG);
    return builder.build();
  }
  
  MultiSigOutputScript.convert(Script script) : super(script.bytes) {
    if(!matchesType(script)) throw new ScriptException("Given script is not an instance of this script type.");
  }
  
  int get threshold {
    return Script.decodeFromOpN(chunks[0].data[0]);
  }
  
  List<KeyPair> get pubKeys {
    List<KeyPair> keys = new List();
    for(int i = 0 ; i < (chunks.length - 3) ; i++) {
      keys.add(new KeyPair(chunks[i+1].data));
    }
    return keys;
  }
  
  static bool matchesType(Script script) {
    // script length must be 3 + #pubkeys with max 16 pubkeys
    if(script.chunks.length < 4 || script.chunks.length > 19)
      return false;
    // second chunks must be OP_N code with threshold, value from 0 to 16
    if(Script.decodeFromOpN(script.chunks[0].data[0]) < 0 || Script.decodeFromOpN(script.chunks[0].data[0]) > 16)
      return false;
    // intermediate chunks must be data chunks. these are the pubkeys
    for(int i = 0 ; i < (script.chunks.length - 3) ; i++) {
      if(script.chunks[i+1].data.length <= 1)
        return false;
    }
    // one but last chunk must be OP_N code with #pubkeys, must be #chunks - 1
    if(Script.decodeFromOpN(script.chunks[script.chunks.length-2].data[0]) != script.chunks.length - 3)
      return false;
    // last chunk must be OP_MULTISIG opcode
    return script.chunks[script.chunks.length-1].equalsOpCode(ScriptOpCodes.OP_CHECKMULTISIG);
  }
}