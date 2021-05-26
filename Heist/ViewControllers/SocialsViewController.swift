//
//  SocialsViewController.swift
//  Heist
//
//  Created by Shrawan Sah on 27/04/21.
//

import UIKit
import WebKit
import GoogleSignIn
import Swifter
import SafariServices

class SocialsViewController: UIViewController, WKNavigationDelegate, GIDSignInDelegate {
    
    var webView = WKWebView()
    var linkedInData: [String:Any] = [:]
    var googleData: [String:Any] = [:]
    
    var userID: String = ""
    var window: UIWindow?
    
    var swifter: Swifter!
    var twitterAccToken: Credential.OAuthAccessToken?
    
    var twitterAuthRespTokens = [String:String]()



    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        webView.frame = view.bounds
        webView.navigationDelegate = self
    }

    
    /**
     IBAction deligates
     */
    @IBAction func linkedInButtonPressed(_ sender: Any) {
        self.startLinkedInAuthorization()
    }

    @IBAction func twitterButtonPressed(_ sender: Any) {
        self.startTwitterAuthorization()
    }
    
    @IBAction func instagramButtonPressed(_ sender: Any) {
    }
    
    @IBAction func googlebuttonPressed(_ sender: Any) {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().presentingViewController = self
        GIDSignIn.sharedInstance().scopes = ["https://www.googleapis.com/auth/calendar", "https://www.googleapis.com/auth/contacts.readonly"]
        
        // Initialize sign-in
        GIDSignIn.sharedInstance().clientID = "801584951626-kr30p8ftn197l0umuccjcsqrr1nm2i6j.apps.googleusercontent.com"
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
        // Automatically sign in the user.
        GIDSignIn.sharedInstance()?.restorePreviousSignIn()
        
        GIDSignIn.sharedInstance()?.signIn()

    }
    
    
    /**
     Google Sign in delegates
     */

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
      // Initialize sign-in
      GIDSignIn.sharedInstance().clientID = "801584951626-kr30p8ftn197l0umuccjcsqrr1nm2i6j.apps.googleusercontent.com"
      GIDSignIn.sharedInstance().delegate = self
      GIDSignIn.sharedInstance()?.restorePreviousSignIn()

      return true
    }
    
    
    func application(_ application: UIApplication,
                     open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
      return GIDSignIn.sharedInstance().handle(url)
    }
    
    
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
      return GIDSignIn.sharedInstance().handle(url)
    }
    
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
      if let error = error {
        if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
          print("The user has not signed in before or they have since signed out.")
        } else {
          print("\(error.localizedDescription)")
        }
        NotificationCenter.default.post(
          name: Notification.Name(rawValue: "ToggleAuthUINotification"), object: nil, userInfo: nil)
        return
      }
        
      self.googleData["user"] = user
        
        
        let jsonTodo: Data
        var postData: [String: Any] = [:]
        
        do {
            postData["google"] = [
                "user" : self.googleData
            ]
            postData["device_type"] = "ios_app"
            postData["user_id"] = self.userID
            postData["is_api"] = true;
            
            jsonTodo = try JSONSerialization.data(withJSONObject: postData, options: [])
        } catch {
          print("Error: cannot create JSON from location postData")
          return
        }
        self.saveUserData(jsonTodo: jsonTodo)

      NotificationCenter.default.post(
        name: Notification.Name(rawValue: "ToggleAuthUINotification"),
        object: nil,
        userInfo: ["statusText": "Signed in user:\n\(user.profile.name!)"])
    }
    
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
      NotificationCenter.default.post(
        name: Notification.Name(rawValue: "ToggleAuthUINotification"),
        object: nil,
        userInfo: ["statusText": "User has disconnected."])
    }
    
    /**
     Google Sign in delegates ends
     */
    
    
    
    
    
    /**
     Webview deligates
     */
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction:WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        let request = navigationAction.request
        let url = request.url
        
        if request.url?.absoluteString.contains("undostres.com.mx") != nil {
            if url?.absoluteString.range(of: "code") != nil {
                let urlParts = url?.absoluteString.components(separatedBy: "?")
                guard let code = urlParts?[1].components(separatedBy: "=")[1] else { return }
                
                // request for access token
                requestLinkedInAccessToken(authorizationCode: code)
            }
        }
        
        decisionHandler(.allow)
        return
    }
    /**
     Webview deligates ends
     */
    
    
    /**
     Twitter Sign in delegates
     */
    func startTwitterAuthorization() {
                
        self.swifter = Swifter(consumerKey: TwitterConfigs.TWITTER_API_KEY, consumerSecret: TwitterConfigs.TWITTER_SECRET_KEY)
        self.swifter.authorize(withCallback: URL(string: TwitterConfigs.TWITTER_REDIRECT_URL)!, presentingFrom: self, success: { accessToken, _ in
            print(accessToken)
            self.twitterAccToken = accessToken
        }, failure: { _ in
            print("ERROR: Trying to authorize")
        })
    }
    
    /**
     Twitter Sign in delegates end
     */
    
    
    
    /**
    LinkedIn Deligates
     */
    func startLinkedInAuthorization() {
        // Specify the response type which should always be "code".
        let responseType = "code"

        // Set the redirect URL which you have specify at time of creating application in LinkedIn Developer’s website. Adding the percent escape characthers is necessary.
        let redirectURL = LinkedInConfigs.LINKED_IN_REDIRECT_URL.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        // Create a random string based on the time interval (it will be in the form linkedin12345679).
        let state = "linkedin\(Int(NSDate().timeIntervalSince1970))"

        // Set preferred scope.
        let scope = "r_liteprofile,r_emailaddress"
        
        // Create the authorization URL string.
        var authorizationURL = "\(LinkedInConfigs.LINKED_IN_AUTHORIZATON_ENDPOINT)?"
        authorizationURL += "response_type=\(responseType)&"
        authorizationURL += "client_id=\(LinkedInConfigs.LINKED_IN_AUTHENTICATION_KEY)&"
        authorizationURL += "redirect_uri=\(redirectURL)&"
        authorizationURL += "state=\(state)&"
        authorizationURL += "scope=\(scope)"
        
        guard let url = URL(string: authorizationURL) else {
            print("error creating URL")
            return
        }
        
        view.addSubview(webView)
        webView.load(URLRequest(url: url))
    }
    
    func requestLinkedInAccessToken(authorizationCode: String) {
        
        let grantType = "authorization_code"
        let redirectURL = LinkedInConfigs.LINKED_IN_REDIRECT_URL.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
        
        // Set the POST parameters.
        var postParams = "grant_type=\(grantType)&"
        postParams += "code=\(authorizationCode)&"
        postParams += "redirect_uri=\(redirectURL)&"
        postParams += "client_id=\(LinkedInConfigs.LINKED_IN_AUTHENTICATION_KEY)&"
        postParams += "client_secret=\(LinkedInConfigs.LINKED_IN_CLIENT_SECRET)"
        
        // Convert the POST parameters into NSData object.
        let postData = postParams.data(using: String.Encoding.utf8)
        
        // Initialize a mutable URL request object using the access token endpoint URL string.
        let request = NSMutableURLRequest(url: NSURL(string: LinkedInConfigs.LINKED_IN_ACCESS_TOKEN_ENDPOINT)! as URL)
        
        request.httpMethod = "POST"
        request.httpBody = postData
        request.addValue("application/x-www-form-urlencoded;", forHTTPHeaderField: "Content-Type")
        
        // Initialize a NSURLSession object
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        // Make the request.
        let task: URLSessionDataTask = session.dataTask(with: request as URLRequest) {(data, response, error) -> Void in
            let statusCode = (response as! HTTPURLResponse).statusCode
            
            if statusCode == 200 {
                // Convert JSON to Dictionary
                do {
                    let dataDictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)
                    let accessToken = (dataDictionary as! [String:Any]) ["access_token"] as! String
                    print ("LinkedIn Access Token :: \(accessToken)")
                    self.requestForLiteProfile(accessToken: accessToken)
                    self.requestForEmailAddress(accessToken: accessToken)
                    
                } catch {
                    print ("could not convert JSON into a dictionary")
                }
            }
        }
        task.resume()
    }
    
    func requestForLiteProfile(accessToken:String) {
        let targetURL = "https://api.linkedin.com/v2/me?projection=(id,firstName,lastName,profilePicture(displayImage~:playableStreams))"
        let url = URL.init(string: targetURL)
        var request = URLRequest.init(url: url!)
        
        request.httpMethod = "GET"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let session = URLSession.init(configuration: .default)
        
        // Make the request.
        let task = session.dataTask(with: request) {(data, response, error) -> Void in
            let statusCode = (response as! HTTPURLResponse).statusCode
            
            if statusCode == 200 {
                // Convert JSON to Dictionary
                do {
                    let dataDictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)
                    
                    if let jsonDictionary = dataDictionary as? [String: Any] {
                        print(jsonDictionary)
                        self.linkedInData["lite_profile_response"] = jsonDictionary
                    }
                    
                } catch {
                    print ("could not convert JSON into a dictionary")
                }
                
                
                let jsonTodo: Data
                var postData: [String: Any] = [:]
                
                do {
                    postData["linkedIn"] = [
                        "lite_profile_response" : self.linkedInData["lite_profile_response"]
                    ]
                    postData["device_type"] = "ios_app"
                    postData["user_id"] = self.userID
                    postData["is_api"] = true;
                    
                    jsonTodo = try JSONSerialization.data(withJSONObject: postData, options: [])
                } catch {
                  print("Error: cannot create JSON from location postData")
                  return
                }
                self.saveUserData(jsonTodo: jsonTodo)
            }
        }
        task.resume()
    }
    
    func requestForEmailAddress(accessToken:String) {
        
        let targetURL = "https://api.linkedin.com/v2/emailAddress?q=members&projection=(elements*(handle~))"
        let url = URL.init(string: targetURL)
        var request = URLRequest.init(url: url!)
        
        request.httpMethod = "GET"
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let session = URLSession.init(configuration: .default)
        
        // Make the request.
        let task = session.dataTask(with: request) {(data, response, error) -> Void in
            let statusCode = (response as! HTTPURLResponse).statusCode
            
            if statusCode == 200 {
                // Convert JSON to Dictionary
                do {
                    let dataDictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)
                    
                    if let jsonDictionary = dataDictionary as? [String: Any] {
                        print(jsonDictionary)
                        self.linkedInData["email_response"] = jsonDictionary
                    }
                } catch {
                    print ("could not convert JSON into a dictionary")
                }
                
                let jsonTodo: Data
                var postData: [String: Any] = [:]
                
                do {
                    postData["linkedIn"] = [
                        "email_response" : self.linkedInData["email_response"]
                    ]
                    postData["device_type"] = "ios_app"
                    postData["user_id"] = self.userID
                    postData["is_api"] = true;
                    
                    jsonTodo = try JSONSerialization.data(withJSONObject: postData, options: [])
                } catch {
                  print("Error: cannot create JSON from location postData")
                  return
                }
                self.saveUserData(jsonTodo: jsonTodo)
            }
        }
        task.resume()
    }
    /**
    LinkedIn Deligates
     */
    
    
    func saveUserData(jsonTodo: Data) {
        print ("inside saveUserData")
        print ("POST = > \(jsonTodo)")
        
        let todosEndpoint: String = "https://be772f87a164.ngrok.io/insertPermissions.php"
        guard let todosURL = URL(string: todosEndpoint) else {
          print("Error: cannot create URL")
          return
        }
        var todosUrlRequest = URLRequest(url: todosURL)
        todosUrlRequest.httpMethod = "POST"
        todosUrlRequest.httpBody = jsonTodo

        let session = URLSession.shared

        let task = session.dataTask(with: todosUrlRequest) {
          (data, response, error) in
          guard error == nil else {
            print("error calling POST on /todos/1")
            print(error as Any)
            return
          }
          guard let responseData = data else {
            print("Error: did not receive data")
            return
          }
          
          // parse the result as JSON, since that's what the API provides
          do {
            guard let receivedTodo = try JSONSerialization.jsonObject(with: responseData,
              options: []) as? [String: Any] else {
                print("Could not get JSON from responseData as dictionary")
                return
            }
            print("The response todo is: " + receivedTodo.description)
            
            guard let todoID = receivedTodo["id"] as? Int else {
              print("Could not get todoID as int from JSON")
              return
            }
            print("The ID is: \(todoID)")
          } catch  {
            print("error parsing response from POST on /todos")
            return
          }
        }
        task.resume()
    }
}


extension SocialsViewController: SFSafariViewControllerDelegate {
    
    func safariViewController(_ controller: SFSafariViewController, initialLoadDidRedirectTo URL: URL) {
        if URL.absoluteString.contains("https://undostres.com.mx/") {
            let components = URLComponents(url: URL, resolvingAgainstBaseURL: false)!
            if let queryItems = components.queryItems {
                for item in queryItems {
                    self.twitterAuthRespTokens[item.name] = item.value!
                }
            }
            
            print(twitterAuthRespTokens)

            
            let jsonTodo: Data
            var postData: [String: Any] = [:]
            
            do {
                postData["twitter"] = [
                    "auth_resp_tokens" : self.twitterAuthRespTokens
                ]
                postData["device_type"] = "ios_app"
                postData["user_id"] = self.userID
                postData["is_api"] = true;
                
                jsonTodo = try JSONSerialization.data(withJSONObject: postData, options: [])
            } catch {
              print("Error: cannot create JSON from location postData")
              return
            }
            self.saveUserData(jsonTodo: jsonTodo)
        }
        

    }
}
