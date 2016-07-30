# MongoKitten

[![Swift 2.2](https://img.shields.io/badge/swift-2.2-green.svg)](https://swift.org)
[![Swift 3.0](https://img.shields.io/badge/swift-3.0-orange.svg)](https://swift.org)
![License](https://img.shields.io/github/license/openkitten/mongokitten.svg)
[![Slack Status](http://orlandos.nl:3000/badge.svg)](http://orlandos.nl:3000/)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)


Native MongoDB driver for Swift, written in Swift. This library does not wrap around the mongoc driver. It uses:

- [Strand](https://github.com/qutheory/Strand) for fetching server responses without blocking the thread
- Our own [BSON](https://github.com/OpenKitten/BSON) library, which is also 100% native Swift
- Our own [MD5](https://github.com/CryptoKitten/MD5), [SHA1](https://github.com/CryptoKitten/SHA1) and [SCRAM](https://github.com/CryptoKitten/SCRAM) libraries in 100% Swift

## Documentation

This can be found [here](http://openkitten.github.io/MongoKitten/docs/).

We have our own Dash documentation for MongoKitten which can be found in the top-right corner of the Documentation.

## Requirements

- A MongoDB server
- Some basic knowledge of MongoDB or time to research about MongoDB
- The swift version described in `.swift-version`, see [swiftenv](http://swiftenv.fuller.li/en/latest/).

We don't support any other version of swift with the constantly changing syntax. This required swift version changes constantly with newer versions of `MongoKitten` and it's recommended to pin down the version in SPM.

Note: other versions of `swift` and `MongoDB` may or may not work. We do not support them.

#### Running Unit Tests
The unit tests expect a test database. Run the Tools/testprep.sh script to import it.

# Tutorial

## Setup

### Swift 3.0 (SPM)

Add `MongoKitten` to your Package.swift:

```swift
import PackageDescription

let package = Package(
	name: "MyApp",
	dependencies: [
		.Package(url: "https://github.com/OpenKitten/MongoKitten.git", majorVersion: 1, minor: 1)
	]
)
```

### Swift 2.2 (Carthage)

Add `MongoKitten` to your Cartfile:

```
github "OpenKitten/MongoKitten" ~> 1.1
```

For further instructions, see the [Carthage readme](https://github.com/Carthage/Carthage).

Note that the tutorial below is written for Swift 3.0. Syntax may be a bit different.

## Basic usage

Import the MongoKitten library:

```swift
import MongoKitten
```

Connect to your local MongoDB server using an URI:

```swift
let server: Server!

do {
	server = try Server("mongodb://username:password@localhost:27017", automatically: true)

} catch {
    // Unable to connect
	print("MongoDB is not available on the given host and port")
}
```

Select a database to use for your application:

```swift
let database = server["mydatabase"]
```

And select your collections to use from the database:

```swift
let userCollection = database["users"]
let otherCollection = database["otherdata"]
```

## Creating Documents

In `MongoKitten` we use our own `BSON` library for working with MongoDB Documents.

You can create a simple user document like this:

```swift
var userDocument: Document = [
	"username": "Joannis",
	"password": "myPassword",
	"age": 19,
	"male": true
]
```

If you want to embed a variable you'll need to use the `~` prefix operator.

```swift
let niceBoolean = true

let testDocument: Document = [
    "example": "data",
    "userDocument": ~userDocument,
    "niceBoolean": ~niceBoolean,
    "embeddedDocument": [
        "name": "Henk",
        "male": false,
        "age": 12,
        "pets": ["dog", "dog", "cat", "cat"]
    ]
]
```

## Using Documents

A Document is similar to a Dictionary. A document however has order and thus the position of elements doesn't change unless you tell it to.
A Document is therefore an array and a dictionary at the same time. With the minor difference that a Document can only hold BSON's `Value`. The problem that arises it when you want to use native types from Swift like a String, Int or another Document (sub-document) and elements in there.
We fixed this with the use of subscripts and getters.

To get a value from the Document you can subscript it like this:

```swift
let username: Value = userDocument["username"]
```

Documents always return a value. When the value doesn't exist we'll return `Value.nothing`.
If you want to get a specific value from the Document like a String we can return an optional String like this:

```swift
let username: String? = userDocument["username"].stringValue
```

However.. for an age you might want a String without receiving `nil` in a case like this:

```swift
let age: String? = userDocument["age"].stringValue
```

We made this easier by converting it for you:

```swift
let age: String = userDocument["age"].string
```

However.. if the age would normally be `.nothing` we'll now return an empty string `""` instead. So check for that!

Last but not least we'll also want to assign data using a subscript. Because subscript are prone to being ambiguous we had to use enums for assignment.

This would result in this:

```swift
userDocument["bool"] = .boolean(true)
userDocument["int32"] = .int32(10)
userDocument["int64"] = .int64(200)
userDocument["array"] = .array(["one", 2, "three"])
userDocument["binary"] = .binary(subtype: .generic, data: [0x00, 0x01, 0x02, 0x03, 0x04])
userDocument["date"] = .dateTime(NSDate())
userDocument["null"] = .null
userDocument["string"] = .string("hello")
userDocument["objectID"] = .objectId(try! ObjectId("507f1f77bcf86cd799439011"))
```

Of course variables can still use the `~` operator:

```swift
let trueBool = true
userDocument["newBool"] = ~trueBool
```


## Inserting Documents

Using the above document you can insert the data in the collection.

```swift
try userCollection.insert(userDocument)
```

In the collection's insert method you can also insert a group of Documents: `[Document]`

```swift
try otherCollection.insert([testDocument, testDocument, testDocument])
```

## Finding data

To find the Documents in the collection we'll want to use `find` or `findOne` on the collection. This returns a "cursor".
The `find` and `findOne` functions are used on a collection and don't require any parameters.
Adding parameters, however, helps finding the data you need. By providing no arguments we're selecing all data in the collection.

```swift
let resultUsers = try userCollection.find()
```

This returns a cursor that you can use to loop over users. `MongoKitten`'s `Cursor` by default loads 10 Documents at a time from `MongoDB` which is customizable to a bigger or smaller amount of Documents.

This allows us to provide a smaller delay when looping over data. This also allows the application to remove the cursor halfway through the Documents without downloading Documents that aren't being used.

Looping over the above results is easy:

```swift
for userDocument in resultUsers {
	 print(userDocument)
	
    if userDocument["username"].stringValue == "harriebob" {
        print(userDocument)
    }
}
```

If you do want all Documents in one array you can use `Array()`.

```swift
let otherResultUsers = try userCollection.find()
let allUserDocuments = Array(otherResultUsers)
```

But be careful.. a cursor contains the data only once.

```swift
let depletedExample = try userCollection.find()

// Contains data
let allUserDocuments = Array(depletedExample)

// Doesn't contain data
let noUserDocuments = Array(depletedExample)
```

### QueryBuilder

We also have a query builder which can be easily used to create filters when searching for Documents.

```swift
let q: Query = "username" == "Joannis" && "age" > 18

let result = try userCollection.findOne(matching: q)
```

Or simpler:

```swift
let newResult = try userCollection.findOne(matching: "username" == "Joannis" && "age" > 18)
```

This comes in handy when looping over data:

```swift
for user in try userCollection.find(matching: "male" == true) {
    print(user["username"].string)
}
```

## Updating data

Updating data is simple too. There is a `multiple` argument for people who update more than one document at a time. This example only updates the first match:

```swift
try userCollection.update(matching: ["username": "Joannis"], to: ["username": "Robbert"])
```

## Deleting data

Deleting is possible using a document and a query

```swift
// Delete using a document
try userCollection.remove(matching: ["username": "Robbert"])
```

## GridFS

```swift
// Make a GridFS Collection within the database 'mydatabase'
let gridFS = GridFS(in: server["mydatabase"])

// Find all bytes corresponding to this image
let data = NSData(contentsOfFile: "./myimage.jpg")!

// Store the file in GridFS with maximum 10000 bytes per chunk (255000 is the recommended default) and doesn't need to be set
// Store the ObjectID corresponding to the file in a constant variable
let objectID = try! gridFS.store(data: data, named "myimage.jpg", withType: "image/jpeg", inChunksOf: 10000)

// Retreive the file from GridFS
let file = try! gridFS.findOne(byID: objectID)

// Get the bytes we need
let myImageData: [Byte] = file!.read(from: 1024, to: 1234)
```

### GridFS example usage

Imagine running a video streaming site. One of your users uploads a video. This will be stored in GridFS within 255000-byte chunks.

Now one user starts watching the video. You'll load the video chunk-by-chunk without keeping all of the video's buffer in memory.

The user quits the video about 40% through the video. Let's say chunk 58 of 144 of your video. Now you'll want to start continueing the video where it left off without receving all the unneccesary chunks.

## License

MongoKitten is licensed under the MIT license.
