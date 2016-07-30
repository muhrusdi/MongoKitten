//
//  MongoError.swift
//  MongoKitten
//
//  Created by Robbert Brandsma on 22-02-16.
//  Copyright © 2016 OpenKitten. All rights reserved.
//

import Foundation
import struct BSON.Document

/// All MongoDB errors
public enum MongoError : Error {
    /// Can't connect to the MongoDB Server
    case mongoDatabaseUnableToConnect
    
    /// Can't connect since we're already connected
    case mongoDatabaseAlreadyConnected
    
    /// Can't disconnect the socket
    case cannotDisconnect
    
    /// The body of this message is an invalid length
    case invalidBodyLength
    
    /// -
    case invalidAction
    
    /// We can't do this action because we're not yet connected
    case notConnected
    
    /// Can't insert given documents
    case insertFailure(documents: [Document], error: Document?)
    
    /// Can't query for documents matching given query
    case queryFailure(query: Document, error: Document?)
    
    /// Can't update documents with the given selector and update
    case updateFailure(updates: [(filter: Document, to: Document, upserting: Bool, multiple: Bool)], error: Document?)
    
    /// Can't remove documents matching the given query
    case removeFailure(removals: [(filter: Document, limit: Int32)], error: Document?)
    
    /// Can't find a handler for this reply
    case handlerNotFound
    
    /// -
    case timeout
    
    /// -
    case commandFailure(error: Document)
    
    /// -
    case commandError(error: String)
    
    /// Thrown when the initialization of a cursor, on request of the server, failed because of missing data.
    case cursorInitializationError(cursorDocument: Document)
    
    /// -
    case invalidReply
    
    /// The response with the given documents is invalid
    case invalidResponse(documents: [Document])
    
    /// If you get one of these, it's probably a bug on our side. Sorry. Please file a ticket :)
    case internalInconsistency
    
    /// -
    case unsupportedOperations
    
    /// -
    case invalidChunkSize(chunkSize: Int)
    
    /// GridFS was asked to return a negative amount of bytes
    case negativeBytesRequested(start: Int, end: Int)

    case invalidURI(uri: String)
    
    case invalidNSURL(url: NSURL)
}

public enum MongoAuthenticationError : Error {
    case base64Failure
    case authenticationFailure
    case serverSignatureInvalid
    case incorrectCredentials
}

internal enum InternalMongoError : Error {
    case incorrectReply(reply: Message)
}
