import 'package:bb_mobile/core/utils/logger.dart';
import 'package:bdk_flutter/bdk_flutter.dart' as bdk;
import 'package:flutter/foundation.dart';

class AddressScriptConversions {
  static Future<String?> bitcoinAddressFromScriptPubkey(
    Uint8List scriptPubkey, {
    required bool isTestnet,
  }) async {
    try {

      if (!isStandardAddressScript(scriptPubkey)) return null;

      final address = await bdk.Address.fromScript(
        script: bdk.ScriptBuf(bytes: scriptPubkey),
        network: isTestnet ? bdk.Network.testnet : bdk.Network.bitcoin,
      );

      return address.asString();
    } catch (e) {
      log.severe(
        message: 'error converting scriptPubkey to address',
        error: e,
        trace: StackTrace.current,
      );
      return null;
    }
  }
}

bool isStandardAddressScript(Uint8List script) {
  if (script.isEmpty) return false;

  final len = script.length;

  // OP_RETURN (provably unspendable)
  if (script[0] == 0x6a) return false;

  // P2PKH: OP_DUP OP_HASH160 <20> OP_EQUALVERIFY OP_CHECKSIG
  if (len == 25 &&
      script[0] == 0x76 &&
      script[1] == 0xa9 &&
      script[2] == 0x14 &&
      script[23] == 0x88 &&
      script[24] == 0xac){
    return true;
  }

  // P2SH: OP_HASH160 <20> OP_EQUAL
  if (len == 23 &&
      script[0] == 0xa9 &&
      script[1] == 0x14 &&
      script[22] == 0x87){
    return true;
  }

  // P2WPKH: OP_0 <20>
  if (len == 22 &&
      script[0] == 0x00 &&
      script[1] == 0x14){
    return true;
  }

  // P2WSH: OP_0 <32>
  if (len == 34 &&
      script[0] == 0x00 &&
      script[1] == 0x20){
    return true;
  }

  // P2TR: OP_1 <32>
  if (len == 34 &&
      script[0] == 0x51 &&
      script[1] == 0x20){
    return true;
  }

  log.fine('script type is non-standard');
  return false;
}
