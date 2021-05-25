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
    var linkedInData = [String:Any]()
    
    var swifter: Swifter!
    var twitterAccToken: Credential.OAuthAccessToken?
    
    var twitterId = ""
    var twitterHandle = ""
    var twitterName = ""
    var twitterEmail = ""
    var twitterProfilePicURL = ""
    var twitterAccessToken = ""

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
        self.swifter = Swifter(consumerKey: TwitterConfigs.TWITTER_API_KEY, consumerSecret: TwitterConfigs.TWITTER_SECRET_KEY)
             self.swifter.authorize(withCallback: URL(string: TwitterConfigs.TWITTER_REDIRECT_URL)!, presentingFrom: self, success: { accessToken, _ in
                 self.twitterAccToken = accessToken
                 self.getUserProfile()
             }, failure: { _ in
                 print("ERROR: Trying to authorize")
        })
    }
    
    func getUserProfile() {
            self.swifter.verifyAccountCredentials(includeEntities: false, skipStatus: false, includeEmail: true, success: { json in
                // Twitter Id
                if let twitterId = json["id_str"].string {
                    print("Twitter Id: \(twitterId)")
                } else {
                    self.twitterId = "Not exists"
                }

                // Twitter Handle
                if let twitterHandle = json["screen_name"].string {
                    print("Twitter Handle: \(twitterHandle)")
                } else {
                    self.twitterHandle = "Not exists"
                }

                // Twitter Name
                if let twitterName = json["name"].string {
                    print("Twitter Name: \(twitterName)")
                } else {
                    self.twitterName = "Not exists"
                }

                // Twitter Email
                if let twitterEmail = json["email"].string {
                    print("Twitter Email: \(twitterEmail)")
                } else {
                    self.twitterEmail = "Not exists"
                }

                // Twitter Profile Pic URL
                if let twitterProfilePic = json["profile_image_url_https"].string?.replacingOccurrences(of: "_normal", with: "", options: .literal, range: nil) {
                    print("Twitter Profile URL: \(twitterProfilePic)")
                } else {
                    self.twitterProfilePicURL = "Not exists"
                }
                print("Twitter Access Token: \(self.twitterAccToken?.key ?? "Not exists")")
                
                
                // TODO:: save this data

            }) { error in
                print("ERROR: \(error.localizedDescription)")
            }
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
    var window: UIWindow?

    // [START didfinishlaunching]
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
      // Initialize sign-in
      GIDSignIn.sharedInstance().clientID = "801584951626-kr30p8ftn197l0umuccjcsqrr1nm2i6j.apps.googleusercontent.com"
      GIDSignIn.sharedInstance().delegate = self
      GIDSignIn.sharedInstance()?.restorePreviousSignIn()

      return true
    }
    // [END didfinishlaunching]
    
    
    // [START openurl]
    func application(_ application: UIApplication,
                     open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
      return GIDSignIn.sharedInstance().handle(url)
    }
    // [END openurl]
    
    
    // [START openurl_new]
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
      return GIDSignIn.sharedInstance().handle(url)
    }
    // [END openurl_new]
    
    
    // [START signin_handler]
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
      if let error = error {
        if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
          print("The user has not signed in before or they have since signed out.")
        } else {
          print("\(error.localizedDescription)")
        }
        // [START_EXCLUDE silent]
        NotificationCenter.default.post(
          name: Notification.Name(rawValue: "ToggleAuthUINotification"), object: nil, userInfo: nil)
        // [END_EXCLUDE]
        return
      }
        
      // Perform any operations on signed in user here.
      let userId = user.userID                  // For client-side use only!
      let idToken = user.authentication.idToken // Safe to send to the server
      let fullName = user.profile.name
      let givenName = user.profile.givenName
      let familyName = user.profile.familyName
      let email = user.profile.email
        
        // TODO:: save this data
      
        // [START_EXCLUDE]
      NotificationCenter.default.post(
        name: Notification.Name(rawValue: "ToggleAuthUINotification"),
        object: nil,
        userInfo: ["statusText": "Signed in user:\n\(fullName!)"])
      // [END_EXCLUDE]
    }
    // [END signin_handler]
    
    
    // [START disconnect_handler]
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
      // Perform any operations when the user disconnects from app here.
      // [START_EXCLUDE]
      NotificationCenter.default.post(
        name: Notification.Name(rawValue: "ToggleAuthUINotification"),
        object: nil,
        userInfo: ["statusText": "User has disconnected."])
      // [END_EXCLUDE]
    }
    // [END disconnect_handler]
    
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
                    
                    // TODO:: save this data
                    
                    
                } catch {
                    print ("could not convert JSON into a dictionary")
                }
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
                    
                    // TODO:: save this data

                    
                } catch {
                    print ("could not convert JSON into a dictionary")
                }
            }
        }
        task.resume()
    }
    /**
    LinkedIn Deligates
     */
}

extension SocialsViewController: SFSafariViewControllerDelegate {
    
}
