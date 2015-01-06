//
//  User.swift
//  SwiftSampleContacts
//
//  Created by Dexter Kim on 2014-12-22.
//  Copyright (c) 2014 DexMobile. All rights reserved.
//

import Foundation
import Alamofire

// To get the respons data as a collection type
@objc public protocol ResponseCollectionSerializable {
    class func collection(#response: NSHTTPURLResponse, representation: AnyObject) -> [Self]
}

// Generic Response Collection Serialization
extension Alamofire.Request {
    public func responseCollection<T: ResponseCollectionSerializable>(completionHandler: (NSURLRequest, NSHTTPURLResponse?, [T]?, NSError?) -> Void) -> Self {
        let serializer: Serializer = { (request, response, data) in
            let JSONSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
            let (JSON: AnyObject?, serializationError) = JSONSerializer(request, response, data)
            if response != nil && JSON != nil {
                return (T.collection(response: response!, representation: JSON!), nil)
            } else {
                return (nil, serializationError)
            }
        }
        
        return response(serializer: serializer, completionHandler: { (request, response, object, error) in
            completionHandler(request, response, object as? [T], error)
        })
    }
}

// User Object, which is from Random User as Json type
final class User: ResponseCollectionSerializable {
    
    let name: UserName
    let SSN: String
    let phone: String
    let cell: String
    let dob: String
    let email: String
    let gender: String
    let location: UserLocation
    let username: String
    let password: String
    let salt: String
    let md5: String
    let sha1: String
    let sha256: String
    let registered: String
    let picture: UserPic
    let version: String
    
    struct UserName {
        var title: String
        var first: String
        var last: String
    }
    
    struct UserLocation {
        var street: String
        var city: String
        var state: String
        var zip: String
    }
    
    struct UserPic {
        var large: String
        var medium: String
        var thumbnail: String
    }
    
    init(JSON: AnyObject) {
        let title = JSON.valueForKeyPath("name.title") as String
        // all characters are lowercase. So, should be captialized for the first character
        let first = (JSON.valueForKeyPath("name.first") as String).capitalizedString
        let last = (JSON.valueForKeyPath("name.last") as String).capitalizedString
        name = UserName(title: title, first: first, last: last)
        
        SSN = JSON.valueForKeyPath("SSN") as String
        phone = JSON.valueForKeyPath("phone") as String
        cell = JSON.valueForKeyPath("cell") as String
        dob = JSON.valueForKeyPath("dob") as String
        email = JSON.valueForKeyPath("email") as String
        gender = JSON.valueForKeyPath("gender") as String
        
        let street = JSON.valueForKeyPath("location.street") as String
        let city = JSON.valueForKeyPath("location.city") as String
        let state = JSON.valueForKeyPath("location.state") as String
        let zip = JSON.valueForKeyPath("location.zip") as String
        location = UserLocation(street: street, city: city, state: state, zip: zip)
        
        username = JSON.valueForKeyPath("username") as String
        password = JSON.valueForKeyPath("password") as String
        salt = JSON.valueForKeyPath("salt") as String
        md5 = JSON.valueForKeyPath("md5") as String
        sha1 = JSON.valueForKeyPath("sha1") as String
        sha256 = JSON.valueForKeyPath("sha256") as String
        registered = JSON.valueForKeyPath("registered") as String
        
        let large = JSON.valueForKeyPath("picture.large") as String
        let medium = JSON.valueForKeyPath("picture.medium") as String
        let thumbnail = JSON.valueForKeyPath("picture.thumbnail") as String
        picture = UserPic(large: large, medium: medium, thumbnail: thumbnail)
        
        version = JSON.valueForKeyPath("version") as String
    }
    
    // protocol function for ResponseCollectionSerializable
    class func collection(#response: NSHTTPURLResponse, representation: AnyObject) -> [User] {
        var users = [User]()
        
        let results = representation.valueForKeyPath("results") as [NSDictionary]
        
        var index = 0
        for user in results {
            let userDetail = user.valueForKeyPath("user") as NSDictionary
            users.append(User(JSON: userDetail))
        }
        
        // Sorting by First name
        users.sort({$0.name.first < $1.name.first})
        
        return users
    }
}