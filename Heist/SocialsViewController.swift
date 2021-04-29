//
//  SocialsViewController.swift
//  Heist
//
//  Created by Shrawan Sah on 27/04/21.
//

import UIKit
import WebKit

class SocialsViewController: UIViewController, WKNavigationDelegate {
    
    var webView = WKWebView()
    var linkedInData = [String:Any]()

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
    }
    
    @IBAction func instagramButtonPressed(_ sender: Any) {
    }
    
    
    
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
            }
        }
        task.resume()
    }
}
