# Objective C/Swift SDK Programming Guide

Welcome to the SDK Programming Guide. This guide is a practical introduction to creating apps for the iOS platform that make use of Virgil Security features. The code examples in this guide are written in both Objective C and Swift.

In this guide you will find code for every task you need to implement in order to create an application using Virgil Security. It also includes a description of the main classes and methods. The aim of this guide is to get you up and running quickly. You should be able to copy and paste the code provided into your own apps and use it with minumal changes.

## Table of Contents

* [Requirements](#requirements)
* [Installation](#installation)
* [Swift note](#swift-note)
* [User and App Credentials](#user-and-app-credentials)
* [Creating a Virgil Card](#creating-a-virgil-card)
* [Search for Virgil Cards](#search-for-virgil-cards)
* [Validating Virgil Cards](#validating-virgil-cards)
* [Revoking a Virgil Card](#revoking-a-virgil-card)
* [Operations with Crypto Keys](#operations-with-crypto-keys)
* [Generate Keys](#generate-keys)
* [Import and Export Keys](#import-and-export-keys)
* [Encryption and Decryption](#encryption-and-decryption)
* [Encrypt Data](#encrypt-data)
* [Decrypt Data](#decrypt-data)
* [Generating and Verifying Signatures](#generating-and-verifying-signatures)
* [Generating a Signature](#generating-a-signature)
* [Verifying a Signature](#verifying-a-signature)
* [Fingerprint Generation](#fingerprint-generation)
* [Release Notes](#release-notes)

## Requirements

- iOS 7.0+

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate VirgilSDK into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'VirgilSDK', '~> 4.0'
end
```

Then, run the following command:

```bash
$ pod install
```

> CocoaPods 0.36+ is required to build VirgilSDK 4.0.0+.

## Swift note

Although VirgilSDK pod is using Objective-C as its primary language it might be quite easily used in a Swift application.
After pod is installed as described above it is necessary to perform the following:

- Create a new header file in the Swift project.
- Name it something like *BridgingHeader.h*
- Put there the following lines:

###### Objective-C
``` objective-c
@import VirgilCrypto;
@import VirgilSDK;
```

- In the Xcode build settings find the setting called *Objective-C Bridging Header* and set the path to your *BridgingHeader.h* file. Be aware that this path is relative to your Xcode project's folder. After adding bridging header setting you should be able to use the SDK.

You can find more information about using Objective-C and Swift in the same project [here](https://developer.apple.com/library/ios/documentation/Swift/Conceptual/BuildingCocoaApps/MixandMatch.html).

## User and App Credentials

When you register an application on the Virgil developer's [dashboard](https://developer.virgilsecurity.com/dashboard), we provide you with an *appId*, *appKey* and *accessToken*.

* **appId** uniquely identifies your application in our services, it is also used to identify the Public key generated in a pair with *appKey*, for example: ```af6799a2f26376731abb9abf32b5f2ac0933013f42628498adb6b12702df1a87```
* **appKey** is a Private key that is used to perform creation and revocation of *Virgil Cards* (Public key) in Virgil services. Also the *appKey* can be used for cryptographic operations to take part in application logic. The *appKey* is generated at the time of creation application and has to be saved in secure place. 
* **accessToken** is a unique string value that provides an authenticated secure access to the Virgil services and is passed with each API call. The *accessToken* also allows the API to associate your app’s requests with your Virgil developer’s account. 

## Connecting to Virgil
Before you can use any Virgil services features in your app, you must first initialize ```VSSClient``` class. You use the ```VSSClient``` object to get access to Create, Revoke and Search for *Virgil Cards* (Public keys). 

### Initializing an API Client

To create an instance of *VSSClient* class, just call its constructor with your application's *accessToken* which you generated on developer's deshboard.

###### Objective-C
```objective-c
@import VirgilCrypto;
@import VirgilSDK;

//...
@property (nonatomic) VSSClient * __nonnull client;
//...
self.client = [[VSSClient alloc] initWithApplicationToken:<#Virgil App Token#>];
//...
```

###### Swift
```swift
//...
private var client: VSSClient!
//..
self.client = VSSClient(applicationToken: <#Virgil App token#>)
//...
```

### Initializing Crypto
The *VSSCrypto* class provides cryptographic operations in applications, such as hashing, signature generation and verification, encryption and decryption.

###### Objective-C
```objective-c
@import VirgilCrypto;
@import VirgilSDK;

//...
@property (nonatomic) VSSCrypto * __nonnull crypto;
//...
self.crypto = [[VSSCrypto alloc] init];
//...
```

###### Swift
```swift
//...
private var crypto: VSSCrypto!
//..
self.crypto = VSSCrypto()
//...
```

## Creating a Virgil Card

A *Virgil Card* is the main entity of the Virgil services, it includes the information about the user and his public key. The *Virgil Card* identifies the user/device by one of his types. 

Collect an *appId* and *appKey* for your app. These parametes are required to create a Virgil Card in your app scope.

###### Objective-C
```objective-c
NSString *appId = <#Your appId#>;
NSString *appKeyPassword = <#Your app key password#>;
NSURL *appKeyDataURL = [[NSBundle mainBundle] URLForResource:<#Your app key name#> withExtension:@"virgilkey"];
NSData *appKeyData = [NSData dataWithContentsOfURL:appKeyDataURL];

VSSPrivateKey *appPrivateKey = [self.crypto importPrivateKey:appKeyData password:appKeyPassword];
```

###### Swift
```swift
let appId = <#T##String: Your appId#>
let appKeyPassword = <#T##String: You app key password#>
let path = Bundle.main.url(forResource: <#Your app key name#>, withExtension: "virgilkey")
let keyData = try? Data(contentsOf: path!)

let appPrivateKey = self.crypto.importPrivateKey(keyData!, password: appKeyPassword)!
```

Generate a new Public/Private keypair using *VSSCrypto* class. 

###### Objective-C
```objective-c
VSSKeyPair *aliceKeys = [self.crypto generateKeyPair];
```

###### Swift
```swift
let aliceKeys = self.crypto.generateKeyPair()
```

Prepare request
###### Objective-C
```objective-c
NSData *exportedPublicKey = [self.crypto exportPublicKey:aliceKeys.publicKey];
VSSCard *card = [VSSCard cardWithIdentity:@"alice" identityType:@"username" publicKey:exportedPublicKey];
```

###### Swift
```swift
let exportedPublicKey = self.crypto.export(publicKey: aliceKeys.publicKey)
let card = VSSCard(identity: "alice", identityType: "username", publicKey: exportedPublicKey)
```

then, use *VSSRequestSigner* class to sign request with owner and app keys.
###### Objective-C
```objective-c
VSSRequestSigner *requestSigner = [[VSSRequestSigner alloc] initWithCrypto:self.crypto];

NSError *error1;
[requestSigner applicationSignRequest:card withPrivateKey:aliceKeys.privateKey error:&error1];
NSError *error2;
[requestSigner authoritySignRequest:card appId:appId withPrivateKey:appPrivateKey error:&error2];
```

###### Swift
```swift
let requestSigner = VSSRequestSigner(crypto: self.crypto)

do {
    try requestSigner.applicationSignRequest(card, with: keyPair.privateKey)
	try requestSigner.authoritySignRequest(card, appId: kApplicationId, with: appPrivateKey)
}
catch let error as Error {
	//...
}
```

Publish a Virgil Card
###### Objective-C
```objective-c
[self.client createCard:card completion:^(VSSCard *card, NSError *error) {
    //...
}];
```

###### Swift
```swift
self.client.createCard(card) { card, error in
	//...
}
```

## Search for Virgil Cards
Performs the `Virgil Card`s search by criteria:
- the *Identities* request parameter is mandatory;
- the *IdentityType* is optional and specifies the *IdentityType* of a `Virgil Card`s to be found;
- the *Scope* optional request parameter specifies the scope to perform search on. Either 'global' or 'application'. The default value is 'application';

###### Objective-C
```objective-c
VSSSearchCards *searchCards = [VSSSearchCards searchCardsWithScope:VSSCardScopeApplication identityType:@"username" identities:@[@"alice", @"bob"]];
[self.client searchCards:searchCards completion:^(NSArray<VSSCard *>* cards, NSError *error) {
	//...
}];
```

###### Swift
```swift
let searchCards = VSSSearchCards(scope: .application, identityType: "username", identities: ["alice", "bob"])
self.client.searchCards(searchCards) { cards, error in
	//...                
}
```

## Validating Virgil Cards
This sample uses *built-in* ```VSSCardValidator``` to validate cards. By default ```VSSCardValidator``` validates only *Cards Service* signature. 


###### Objective-C
```objective-c
VSSCardValidator *validator = [[VSSCardValidator alloc] initWithCrypto:self.crypto];

// Your can also add another Public Key for verification.
// [validator addVerifierWithId:<#Verifier card id#> publicKey:<#Verifier public key#>];

BOOL isValid = [validator validateCard:card];
```

###### Swift
```swift
let validator = VSSCardValidator(crypto: self.crypto)

// Your can also add another Public Key for verification.
// validator.addVerifier(withId: <#Verifier card id#>, publicKey: <#Verifier public key#>)

let isValid = validator.validate(card)
```

## Revoking a Virgil Card
###### Objective-C
```objective-c
VSSRevokeCard *revokeCard = [VSSRevokeCard revokeCardWithId:<#Your cardId#> reason:VSSCardRevocationReasonUnspecified];

VSSRequestSigner *requestSigner = [[VSSRequestSigner alloc] initWithCrypto:self.crypto];
NSError *error;
[requestSigner authoritySignRequest:revokeCard appId:appId withPrivateKey:appPrivateKey error:&error];

[self.client revokeCard:revokeCard completion:^(NSError *error) {
	//...
}];
```

###### Swift
```swift
let revokeCard = VSSRevokeCard(id: <#Your cardId#>, reason: .unspecified)

let requestSigner = VSSRequestSigner(crypto: self.crypto)
do {
	try requestSigner.authoritySignRequest(revokeCard, appId: appId, with: appPrivateKey)
}
catch let error as Error {
	// ...
}

self.client.revokeCard(revokeCard) { error in
	//...
}
```

## Operations with Crypto Keys

### Generate Keys
The following code sample illustrates keypair generation. The default algorithm is ed25519

###### Objective-C
```objective-c
VSSKeyPair *aliceKeys = [self.crypto generateKeyPair];
```

###### Swift
```swift
let aliceKeys = self.crypto.generateKeyPair()
```

### Import and Export Keys
You can export and import your Public/Private keys to/from supported wire representation.

To export Public/Private keys, simply call one of the Export methods:

###### Objective-C
```objective-c
NSData *exportedPrivateKey = [self.crypto exportPrivateKey:aliceKeys.privateKey password:nil];
NSData *exportedPublicKey = [self.crypto exportPublicKey:aliceKeys.privateKey];
```

###### Swift
```swift
let exportedPrivateKey = self.crypto.export(aliceKeys.privateKey, password: nil)
let exportedPublicKey = self.crypto.export(aliceKeys.publicKey)
```

To import Public/Private keys, simply call one of the Import methods:

###### Objective-C
```objective-c
VSSPrivateKey *privateKey = [self.crypto importPrivateKey:exportedPrivateKey password:nil];
VSSPublicKey *publicKey = [self.crypto importPublicKey:exportedPublicKey];
```

###### Swift
```swift
let privateKey = self.crypto.import(exportedPrivateKey, password: nil)
let publicKey = self.crypto.export(aliceKeys.publicKey)
```

## Encryption and Decryption

Initialize Crypto API and generate keypair.
###### Objective-C
```objective-c
VSSCrypto *crypto = [[VSSCrypto alloc] init];
VSSKeyPair *keyPair = [crypto generateKeyPair];
```

###### Swift
```swift
let crypto = VSSCrypto()
let keyPair = crypto.generateKeyPair()
```

### Encrypt Data
Data encryption using ECIES scheme with AES-GCM. You can encrypt either stream or data.
There also can be more than one recipient

*Data*
###### Objective-C
```objective-c
NSData *plainText = [@"Hello, Bob!" dataUsingEncoding:NSUTF8StringEncoding];
NSError *error;
NSData *encryptedData = [self.crypto encryptData:plainText forRecipients:@[aliceKeys.publicKey] error:&error];
```

###### Swift
```swift
let plainText = "Hello, Bob!".data(using: String.Encoding.utf8)
let encryptedData = try? crypto.encryptData(plainText, forRecipients: [aliceKeys.publicKey])
```

*Stream*
```objective-c
NSURL *fileURL = [[NSBundle mainBundle] URLForResource:<#Your data file name#> withExtension:<#Your data file extension#>];
NSInputStream *inputStreamForEncryption = [[NSInputStream alloc] initWithURL:fileURL];
NSOutputStream *outputStreamForEncryption = [[NSOutputStream alloc] initToMemory];

NSError *error;
[self.crypto encryptStream:inputStreamForEncryption outputStream:outputStreamForEncryption forRecipients: @[aliceKeys.publicKey] error:&error];
```

###### Swift
```swift
let fileURL = Bundle.main.url(forResource: <#You data file name#>, withExtension: <#You data file extension#>)!
let inputStreamForEncryption = InputStream(url: fileURL)!
let outputStreamForEncryption = OutputStream.toMemory()

do {
	try self.crypto.encryptStream(inputStreamForEncryption, outputStream: outputStreamForEncryption, forRecipients: [aliceKeys.publicKey])
}
catch let error as Error {
	//...            
}
```

### Decrypt Data
You can decrypt either stream or data using your private key

*Data*
```objective-c
NSError *error;
NSData *decryptedData = [self.crypto decryptData:encryptedData privateKey:aliceKeys.privateKey error:&error];
```

###### Swift
```swift
let decrytedData = try? self.crypto.decryptData(encryptedDta, privateKey: aliceKeys.privateKey)
```

*Stream*

```objective-c
NSURL *fileURL = [[NSBundle mainBundle] URLForResource:<#Your encrypted data file name#> withExtension:<#Your encrypted data file extension#>];
NSInputStream *inputStreamForDecryption = [[NSInputStream alloc] initWithURL:fileURL];
NSOutputStream *outputStreamForDecryption = [[NSOutputStream alloc] initToMemory];

NSError *error;
[self.crypto decryptStream:inputStreamForDecryption outputStream:outputStreamForDecryption privateKey:aliceKeys.privateKey error:&error];
```

###### Swift
```swift
let fileURL = Bundle.main.url(forResource: <#Your encrypted data file name#>, withExtension: <#Your encrypted data file extension#>)!
let inputStreamForDecryption = InputStream(url: fileURL)!
let outputStreamForDecryption = OutputStream.toMemory()

do {
	try self.crypto.decryptStream(inputStreamForDecryption, outputStream: outputStreamForDecryption, privateKey: aliceKeys.privateKey)
}
catch let error as Error {
	//...            
}
```

## Generating and Verifying Signatures
This section walks you through the steps necessary to use the *VirgilCrypto* to generate a digital signature for data and to verify that a signature is authentic.

### Generating a Signature

Sign the SHA-384 fingerprint of either stream or data using your private key. To generate the signature, simply call one of the sign methods:

*Data*
```objective-c
NSData *plainText = [@"Hello, Bob!" dataUsingEncoding:NSUTF8StringEncoding];
NSError *error;
NSData *signature = [self.crypto signData:data privateKey:keyPair.privateKey error:&error];
```

###### Swift
```swift
let plainText = "Hello, Bob!".data(using: String.Encoding.utf8)
let signature = try? self.crypto.sign(plainText, privateKey: aliceKeys.privateKey)
```

*Stream*
```objective-c
NSURL *fileURL = [[NSBundle mainBundle] URLForResource:<#Your data file name#> withExtension:<#Your data file extension#>];
NSInputStream *inputStreamForEncryption = [[NSInputStream alloc] initWithURL:fileURL];
NSData *signature = [self.crypto signStream:inputStreamForEncryption privateKey:aliceKeys.privateKey error:&error];
```

###### Swift
```swift
let fileURL = Bundle.main.url(forResource: <#Your data file name#>, withExtension: <#Your data file extension#>)!
let inputStreamForSignature = InputStream(url: fileURL)!
let signature = try? self.crypto.sign(inputStreamForSignature, privateKey: aliceKeys.privateKey)
```

### Verifying a Signature

Verify the signature of the SHA-384 fingerprint of either stream or a data using Public key. The signature can now be verified by calling the verify method:

*Data*
```objective-c
NSError *error;
BOOL isVerified = [self.crypto verifyData:data signature:signature signerPublicKey:aliceKeys.publicKey error:&error];
```

###### Swift
```swift
let isVerified = try? self.crypto.verifyData(data, signature: signature, signerPublicKey: aliceKeys.publicKey)
```

*Stream*
```objective-c
NSError *error;
BOOL isVerified = [self.crypto verifyStream:strean signature:signature signerPublicKey:aliceKeys.publicKey error:&error];
```

###### Swift
```swift
let isVerified = try? self.crypto.verifyStream(stream, signature: signature, signerPublicKey: aliceKeys.publicKey)
```

## Fingerprint Generation
The default Fingerprint algorithm is SHA-256.
```objective-c
VSSFingerprint *fingerprint = [self.crypto calculateFingerprintForData:data];
```

###### Swift
```swift
let fingerprint = self.crypto.calculateFingerprint(for: data)
```

## Release Notes
- Please read the latest note here: [https://github.com/VirgilSecurity/virgil-sdk-x/releases](https://github.com/VirgilSecurity/virgil-sdk-x/releases)
