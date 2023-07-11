# Constantine
# Copyright (c) 2018-2019    Status Research & Development GmbH
# Copyright (c) 2020-Present Mamy André-Ratsimbazafy
# Licensed and distributed under either of
#   * MIT license (license terms in the root directory or at http://opensource.org/licenses/MIT).
#   * Apache v2 license (license terms in the root directory or at http://www.apache.org/licenses/LICENSE-2.0).
# at your option. This file may not be copied, modified, or distributed except according to those terms.

import
  ../constantine/ethereum_evm_precompiles,
  std/unittest

suite "EVM ModExp precompile (EIP-198)":
  test "Audit #5 - Fuzz failure with even modulus":
    let input = [

        # Length of base (1)
        uint8 0x00,
              0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01,

        # Length of exponent (1)
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01,

        # Length of modulus (1)
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01,

        # Base
        0x06,

        # Exponent
        0x02,

        # Modulus
        0x04
    ]

    var r = newSeq[byte](1)
    let status = r.eth_evm_modexp(input)
    doAssert status == cttEVM_Success
    doAssert r[0] == 0, ". Result was " & $r[0]

  test "Audit #8 - off-by-1 buffer overflow - ptr + length exclusive vs openArray(lo, hi) inclusive":
    let input = [
        # Length of base (24)
        uint8 0x00,
              0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x18,

        # Length of exponent (36)
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x24,

        # Length of modulus (56)
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x38,

        # Base
        0x07, 0x19, 0x2b, 0x95, 0xff, 0xc8, 0xda, 0x78, 0x63, 0x10, 0x11, 0xed, 0x6b, 0x24, 0xcd, 0xd5,
        0x73, 0xf9, 0x77, 0xa1, 0x1e, 0x79, 0x48, 0x11,

        # Exponent
        0x03, 0x67, 0x68, 0x54, 0xfe, 0x24, 0x14, 0x1c, 0xb9, 0x8f, 0xe6, 0xd4, 0xb2, 0x0d, 0x02, 0xb4,
        0x51, 0x6f, 0xf7, 0x02, 0x35, 0x0e, 0xdd, 0xb0, 0x82, 0x67, 0x79, 0xc8, 0x13, 0xf0, 0xdf, 0x45,
        0xbe, 0x81, 0x12, 0xf4,

        # Modulus
        0x1a, 0xbf, 0x81, 0x1f, 0x86, 0xe1, 0x02, 0x78, 0x66, 0xe4, 0x23, 0x65, 0x49, 0x0f, 0x8d, 0x6e,
        0xc2, 0x23, 0x94, 0x18, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
        0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    ]

    var r = newSeq[byte](56)
    let status = r.eth_evm_modexp(input)
    doAssert status == cttEVM_Success