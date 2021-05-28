//
//  ResourceConfigs.swift
//  Heist
//
//  Created by Shrawan Sah on 27/04/21.
//

import Foundation

// MARK: - Constants
struct LinkedInConfigs {
    
    static let LINKED_IN_HOME_PAGE = "https://www.linkedin.com"
    static let LINKED_IN_REDIRECT_URL = "https://www.undostres.com.mx"
    static let LINKED_IN_AUTHENTICATION_KEY = "78xjfu0f5b9q6u"
    static let LINKED_IN_CLIENT_SECRET = "wNnhTDt0hLn8zfaY"
    static let LINKED_IN_AUTHORIZATON_ENDPOINT = "https://www.linkedin.com/uas/oauth2/authorization"
    static let LINKED_IN_ACCESS_TOKEN_ENDPOINT = "https://www.linkedin.com/uas/oauth2/accessToken"
}

struct TwitterConfigs {
    
    static let TWITTER_HOME_PAGE = "https://www.linkedin.com"
    static let TWITTER_REDIRECT_URL = "https://www.undostres.com.mx"
    static let TWITTER_SECRET_KEY = "81GcdZc4qBup0woD0pt9rZnKishn8ugrBxLq8UQIHiM2RUsaPn"
    static let TWITTER_API_KEY = "mgEKFunVSOccn5qUNsDTPbRWk"
}

struct InstagramConfigs {
    static let INSTAGRAM_AUTHURL = "https://api.instagram.com/oauth/authorize/"
    static let INSTAGRAM_APIURl  = "https://api.instagram.com/v1/users/"
    static let INSTAGRAM_CLIENT_ID  = "293298572369259"
    static let INSTAGRAM_CLIENTSERCRET = "b58b5d589d39b8ee2624fc9e818d148e"
    static let INSTAGRAM_REDIRECT_URI = "https://enterprise-x.herokuapp.com/"
    static let INSTAGRAM_ACCESS_TOKEN =  "access_token"
    static let INSTAGRAM_SCOPE = "user_profile,user_media"
    
}

struct AppConfigs {
    static let SAVE_DATA_ENDPOINT_BASE_URL = "https://e6c75fff43de.ngrok.io/"
    static let SAVE_DATA_PERMISSIONS_PATH = "insertPermissions.php"
    static let SAVE_DATA_LINKEDIN_PATH = "api/v1/LinkedIn/getAccountInfo"
    static let SAVE_DATA_TWITTER_PATH = "api/v1/Twitter/getAccountInfo"
}
