//
//  main.swift
//  TimeProfiler
//
//  Created by Patrick Battisti Forsthofer on 23/02/23.
//

import Foundation

struct Friend: Decodable {
    let id: UUID
    let isActive: Bool
    let name: String
    let age: Int
    let company: String
    let email: String
    let address: String
    let registered: String
    let tags: [String]
    let friends: [LinkedFriend]
}

struct LinkedFriend: Decodable {
    let id: UUID
    let name: String
}

// load and decode the file
let url = URL(fileURLWithPath: NSHomeDirectory() + "/Desktop/input.json")
let users = decode([Friend].self, from: url, dateDecodingStrategy: .iso8601)
sleep(1)


// count how many online friends there are
var total = 0

let start = CFAbsoluteTimeGetCurrent()

for user in users {
    for friend in user.friends {
        if users.contains(where: {
            $0.name == friend.name && user.isActive
        }) {
            total += 1
        }
    }
}

// print the result and timing
let end = CFAbsoluteTimeGetCurrent()
print("Online friends: \(total)")
print("Took \(end - start) seconds")
