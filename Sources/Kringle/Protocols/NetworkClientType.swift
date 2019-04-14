//
//  NetworkClientType.swift
//  Kringle
//
//  Created by Jeff Kereakoglow on 4/14/19.
//

import Foundation
import Promises

public protocol NetworkClientType {
    func get(endpoint: Endpoint) -> Promise<Void>
    func get<T: Decodable>(endpoint: Endpoint, contract: T.Type) -> Promise<T>

    func put(endpoint: Endpoint, body: Data) -> Promise<Void>
    func put<T: Decodable>(endpoint: Endpoint, body: Data, contract: T.Type) -> Promise<T>

    func post(endpoint: Endpoint, body: Data) -> Promise<Void>
    func post<T: Decodable>(endpoint: Endpoint, body: Data, contract: T.Type) -> Promise<T>

    func delete(endpoint: Endpoint) -> Promise<Void>
    func delete<T: Decodable>(endpoint: Endpoint, contract: T.Type) -> Promise<T>
}
