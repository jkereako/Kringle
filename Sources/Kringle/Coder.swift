//
//  Coder.swift
//  Kringle
//
//  Created by Jeff Kereakoglow on 4/14/19.
//

import Foundation
import Promises

// JSONEncoder and JSONDecoder perform their respective work on the the UI thread by default. As
// such, we indicate to the Promise that we want this work to occur on a background thread.
public final class Coder: CoderType {

    /// The dispatch queue for the background thread.
    private let dispatchQueue = DispatchQueue(label: "JSONCoderQueue")

    public init() {}

    /// Asynchronously encodes a contract to JSON data.
    ///
    /// - Parameter contract: The struct from which JSON will be serialized
    /// - Returns: a Data instance of encoded JSON
    public func encode<T: Encodable>(_ contract: T) -> Promise<Data> {
        return Promise<Data>(on: dispatchQueue) { fulfill, reject in
            do {
                let encoded = try JSONEncoder().encode(contract)

                fulfill(encoded)
            } catch {
                reject(error)
            }
        }
    }

    /// Asynchronously decodes JSON data into a contract
    ///
    /// - Parameters:
    ///   - data: The JSON data to decode
    ///   - to: The struct to which JSON will be deserialized
    /// - Returns: A contract
    public func decode<T: Decodable>(_ data: Data, to: T.Type) -> Promise<T> {
        return Promise<T>(on: dispatchQueue) { fulfill, reject in
            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)

                fulfill(decoded)
            } catch {
                reject(error)
            }
        }
    }
}
