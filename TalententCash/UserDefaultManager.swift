//
//  AppManager.swift
//  Talent Cash
//
//  Created by MacBook Pro on 26/12/2022.
//

import Foundation
enum UserType:String {
    case talent = "talent_provider"
    case user   = "user"
    case guest  = "guest"
}
class UserDefaultManager {
    static let instance = UserDefaultManager()
    private var _user:User? = nil
    var user:User? {
        set{
            saveUser(user: newValue)
        }
        get{
            getUser()
        }
    }
    var userID:String {
        get{
            _user?._id ?? ""
        }
    }
    var jwtToken:String {
        get{
            _user?.jwtToken ?? ""
        }
    }
    var userType:UserType{
        get{
            if let user = _user{
                return UserType(rawValue: user.user_role) ?? .guest
            }
            return .guest
        }
    }
    private func saveUser(user:User?) {
        guard let user = user else {
            self._user = nil
            UserDefaults.standard.removeObject(forKey: "LOGGED_USER")
            return
        }
        self._user = user
        do {
            let d = try JSONEncoder().encode(user)
            UserDefaults.standard.set(String(data: d, encoding: .utf8) ?? "", forKey: "LOGGED_USER")
        }catch { }
    }
    private func getUser() -> User? {
        if let user = self._user{
            return user
        }
        do {
            let data = UserDefaults.standard.string(forKey: "LOGGED_USER")?.data(using: .utf8) ?? Data()
            let user = try JSONDecoder().decode(User.self, from: data)
            self._user = user
            return user
        }catch {
            return nil
        }
    }
}
