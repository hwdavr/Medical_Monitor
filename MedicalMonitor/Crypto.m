//
//  Crypto.m
//  MedicalMonitor
//
//  Created by Weidian on 12/11/17.
//  Copyright © 2017 talengineer. All rights reserved.
//

#import "Crypto.h"
#import "Constants.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import "cdecode.h"

@implementation Crypto

#define AES_BLOCK_SIZE 16

+(NSNumber *)decryptValue:(NSString*)encodeString {
    // Decode data
    base64_decodestate _state;
    base64_init_decodestate(&_state);
    const char* encodeData = [encodeString UTF8String];
    NSUInteger encodeLen = [encodeString length];
    //NSLog(@"The encode data is %s, %ld", encodeData, encodeLen);
    char cipher[AES_BLOCK_SIZE * 2];
    base64_decode_block(encodeData, encodeLen, cipher, &_state);
    //NSLog(@"The decoded data is %s", [NSString stringWithUTF8String:cipher]);
    // Derive key
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *userId = [userDefaults objectForKey:KEY_USER_ID];
    NSString *deviceId = [userDefaults objectForKey:KEY_DEVICE_ID];
    NSString *key = [deviceId stringByAppendingString: userId];
    //NSLog(@"The key is %@", key);
    // Fetch key data and put into C string array padded with \0
    const char *keyPtr = [key UTF8String];
    
    // Fetch iv data and put into C string array padded with \0
    char ivPtr[AES_BLOCK_SIZE] = { 0 };
    
    // For block ciphers, the output size will always be less than or equal to the input size plus the size of one block because we add padding.
    // That's why we need to add the size of one block here
    NSUInteger dataLength = AES_BLOCK_SIZE;
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    char *buffer = malloc( bufferSize );
    
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt( kCCDecrypt, kCCAlgorithmAES, kCCOptionPKCS7Padding,
                                          keyPtr, kCCKeySizeAES128,
                                          ivPtr,
                                          cipher, dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesDecrypted );
    //free(keyPtr);
    //free(ivPtr);
    
    if(cryptStatus == kCCSuccess)
    {
        // Make sure the buffer is null terminated, to prevent crash
        buffer[numBytesDecrypted] = '\0';
        NSString *plainString = [NSString stringWithUTF8String:buffer];
        //NSLog(@"The plain string is %@", plainString);
        free(buffer);
        if (plainString == nil) {
            return @0;
        }
        NSNumber *myNumber;
        if ([plainString isEqual:@"true"] || [plainString isEqual:@"True"]) {
            myNumber = @1;
        } else if ([plainString isEqual:@"false"] || [plainString isEqual:@"False"]) {
            myNumber = @0;
        } else {
            NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
            f.numberStyle = NSNumberFormatterDecimalStyle;
            myNumber = [f numberFromString:plainString];
        }
        //NSLog(@"The plain number is %@", myNumber);
        if (myNumber == nil) {
            return @0;
        }
        return myNumber;
    }
    
    free(buffer);
    return @0;
}

@end
