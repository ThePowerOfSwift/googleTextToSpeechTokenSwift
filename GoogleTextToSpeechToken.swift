/*
 (Google Text to Speech token): A swift implementation of the token validation of Google Translate
 inspired by gTTS-token https://github.com/Boudewijn26/gTTS-token
*/


import Foundation

extension String {
    func encodeURIComponent() -> String? {
        let characterSet = NSMutableCharacterSet.alphanumericCharacterSet()
        characterSet.addCharactersInString("-_.!~*'()")
        
        return self.stringByAddingPercentEncodingWithAllowedCharacters(characterSet)
    }
}

extension Character
{
    func unicodeScalarCodePoint() -> UInt32
    {
        let characterString = String(self)
        let scalars = characterString.unicodeScalars
        
        return scalars[scalars.startIndex].value
    }
}

extension String {
    func charAt(integerIndex: Int) -> Character {
        return self[self.startIndex.advancedBy(integerIndex)]
    }
    
    func charCodeAt(integerIndex: Int) -> UInt32 {
        let char = self.charAt(integerIndex)
        return char.unicodeScalarCodePoint()
    }
    
}

extension Int {
    private mutating func shiftLeft(count: Int) -> Int {
        if (self == 0) {
            return self;
        }
        
        let bitsCount : Int = Int (sizeof(Int)) * 8
        let shiftCount = Swift.min(count, bitsCount - 1)
        var shiftedValue:Int = 0;
        
        for bitIdx in 0..<bitsCount {
            // if bit is set then copy to result and shift left 1
            let bit = Int(1 << bitIdx)
            if ((self & bit) == bit) {
                shiftedValue = shiftedValue | (Int(bit) << shiftCount)
            }
        }
        return shiftedValue
        
    }
    private mutating func shiftRight(count: Int) -> Int {
        if (self == 0) {
            return self;
        }
        
        let bitsCount = Int(sizeofValue(self) * 8)
        
        if (count >= bitsCount) {
            return 0
        }
        
        let maxBitsForValue = Int(floor(log2(Double(self)) + 1))
        let shiftCount = Swift.min(count, maxBitsForValue - 1)
        var shiftedValue:Int = 0;
        
        for bitIdx in 0..<bitsCount {
            // if bit is set then copy to result and shift left 1
            let bit = Int(1 << bitIdx)
            if ((self & bit) == bit) {
                shiftedValue = shiftedValue | (bit >> shiftCount)
            }
        }
        return shiftedValue
    }
    
}

func urlCalc(query: String) -> String {
    let SALT_1 = "+-a^+6"
    let SALT_2 = "+-3^+b+-f"
    
    let hours = Int(floor(NSDate().timeIntervalSince1970 / 3600))
    let token_key = hours

    func _work_token(inout a: Int, seed: String) -> Int {
        for i in 0.stride(through: (seed.characters.count - 2), by: 3) {
            let char = seed.charAt(i + 2)
            var d : Int
            if( char >= "a") {
                d = Int(char.unicodeScalarCodePoint()) - 87
            } else {
                d = Int(String(char))!
            }
            
            if(seed.charAt(i+1) == "+") {
                if( a >= 0 ) {
                    d = Int(Int32(truncatingBitPattern: a.shiftRight(d)))
                } else {
                    d = Int(Int32(truncatingBitPattern: (a + 0x100000000) >> d))
                }
            } else {
                d = Int(Int32(truncatingBitPattern: a.shiftLeft(d)))
            }
            
            if(seed.charAt(i) == "+") {
                let e = Int(Int32(truncatingBitPattern: (d & 4294967295)))
                a =  a + e

            } else {
                a = Int(Int32(truncatingBitPattern: a ^ d))
            }
        }
        return a
    }
    
    func calculate_token(text: String) -> String {
        let d = text.unicodeScalars
        
        var a = Int (token_key)
        
        for value in d {
            a += Int(value.value)
            a = _work_token( &a, seed: SALT_1)
        }
        a = _work_token(&a, seed: SALT_2)
        
        if 0 > a {
            a = Int(Int32(truncatingBitPattern: (a & 2147483647))) + 2147483648
        }
        a %= 1000000
        
        let answer = String(a) + "." + String(a ^ Int(token_key))
        
        return answer
    }
    
    return calculate_token(query)
}
let query = "It's working! Fantastic!!!"
let token = urlCalc(query)
let url = "https://translate.google.com/translate_tts?ie=UTF-8&q="  + query.encodeURIComponent()! + "&tl=en&total=1&idx=0&textlen=12&tk=" + token + "&client=t";
print(url)
