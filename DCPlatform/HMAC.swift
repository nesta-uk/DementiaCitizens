//
//  HMAC.swift
//  DCPlatform
//
//  Created by Ben Griffiths on 05/04/2016.
//  Copyright (c) 2016 Nesta (http://www.nesta.org.uk/)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import CommonCrypto

enum CryptoAlgorithm {
  case md5, sha1, sha224, sha256, sha384, sha512

  var hmacAlgorithm: CCHmacAlgorithm {
    var result: Int = 0
    switch self {
    case .md5:      result = kCCHmacAlgMD5
    case .sha1:     result = kCCHmacAlgSHA1
    case .sha224:   result = kCCHmacAlgSHA224
    case .sha256:   result = kCCHmacAlgSHA256
    case .sha384:   result = kCCHmacAlgSHA384
    case .sha512:   result = kCCHmacAlgSHA512
    }
    return CCHmacAlgorithm(result)
  }

  var digestLength: Int {
    var result: Int32 = 0
    switch self {
    case .md5:      result = CC_MD5_DIGEST_LENGTH
    case .sha1:     result = CC_SHA1_DIGEST_LENGTH
    case .sha224:   result = CC_SHA224_DIGEST_LENGTH
    case .sha256:   result = CC_SHA256_DIGEST_LENGTH
    case .sha384:   result = CC_SHA384_DIGEST_LENGTH
    case .sha512:   result = CC_SHA512_DIGEST_LENGTH
    }
    return Int(result)
  }
}

extension String {

  func hmac(_ algorithm: CryptoAlgorithm, key: String) -> String {
    let str = self.cString(using: String.Encoding.utf8)
    let strLen = Int(self.lengthOfBytes(using: String.Encoding.utf8))
    let digestLen = algorithm.digestLength
    let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
    let keyStr = key.cString(using: String.Encoding.utf8)
    let keyLen = Int(key.lengthOfBytes(using: String.Encoding.utf8))

    CCHmac(algorithm.hmacAlgorithm, keyStr!, keyLen, str!, strLen, result)

    let digest = stringFromResult(result, length: digestLen)

    result.deallocate(capacity: digestLen)

    return digest
  }

  fileprivate func stringFromResult(_ result: UnsafeMutablePointer<CUnsignedChar>, length: Int) -> String {
    let hash = NSMutableString()
    for i in 0..<length {
      hash.appendFormat("%02x", result[i])
    }
    return String(hash)
  }

}
