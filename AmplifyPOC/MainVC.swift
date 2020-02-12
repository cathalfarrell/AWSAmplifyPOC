//
//  ViewController.swift
//  AmplifyPOC
//
//  Created by Cathal Tru on 01/07/2019.
//  Copyright © 2019 Cathal Tru. All rights reserved.
//
import AWSMobileClient
import UIKit

var gCognitoToken = ""

class MainVC: UIViewController {

    @IBOutlet weak var signOutBarButton: UIBarButtonItem!
    @IBOutlet weak var signInStateLabel: UILabel!
    @IBOutlet weak var responseLabel: UILabel!

    fileprivate func printTokens() {

        AWSMobileClient.sharedInstance().getTokens { (tokens, error) in
            if let error = error {
                print("Error getting token \(error.localizedDescription)")
            } else if let tokens = tokens {
                /*
                print("😀 ACCESS TOKEN: \(tokens.accessToken!.tokenString!)")
                print("😀 ID TOKEN: \(tokens.idToken!.tokenString!)")
                print("😀 REFRESH TOKEN: \(tokens.refreshToken!.tokenString!)")
                */
                if let idToken = tokens.idToken {
                    gCognitoToken = idToken.tokenString!
                    print("😀 COGNITO ID TOKEN: \(gCognitoToken)")
                }

            }
        }

        AWSMobileClient.sharedInstance().getUserAttributes { (response, error) in
            if error == nil {
                if let resp = response {
                    print("Resp: \(resp)")
                    DispatchQueue.main.async {
                        self.signInStateLabel.text = "Logged In as: \(resp)"
                    }
                }
            } else {
                print("Error: \(error!.localizedDescription)")
            }
        }
    }

    fileprivate func showSignInUI() {
        AWSMobileClient.sharedInstance().showSignIn(navigationController: self.navigationController!, { (_, error) in
            if error == nil {       //Successful signin
                DispatchQueue.main.async {
                    self.signInStateLabel.text = "Logged In"
                    self.signOutBarButton.title = "Sign-Out"
                    self.printTokens()
                    self.showViews()
                }
            }
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        AWSMobileClient.sharedInstance().initialize { (userState, error) in
            if let userState = userState {
                switch userState {
                case .signedIn:
                    DispatchQueue.main.async {
                        self.signInStateLabel.text = "Logged In"
                        self.signOutBarButton.title = "Sign-Out"
                        self.printTokens()
                        self.showViews()
                    }
                case .signedOut:
                    self.showSignInUI()
                default:
                    AWSMobileClient.sharedInstance().signOut()
                }

            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }

    @IBAction func getAssetsTapped(_ sender: Any) {

        AssetService.shared.getAssets { (response) in
            print("Assets completed call: \(response)")
            DispatchQueue.main.async {
                self.responseLabel.text = "\(response)"
            }
        }
    }

    @IBAction func getSingleAssetTapped(_ sender: Any) {

        let assetID = "eeb5c718653d409d84387ad12887365d"

        AssetService.shared.getSingleAsset(identifier: assetID) { (response) in
            print("Single Asset completed call: \(response)")
            DispatchQueue.main.async {
                self.responseLabel.text = "\(response)"
            }
        }
    }

    @IBAction func getUsersTapped(_ sender: Any) {

        UserService.shared.getUsers { (response) in
            print("Users completed call: \(response)")
            DispatchQueue.main.async {
                self.responseLabel.text = "\(response)"
            }
        }
    }

    fileprivate func hideViews() {
        for view in self.view.subviews {
            if let button = view as? UIButton {
                button.isHidden = true
            }
        }

        self.responseLabel.isHidden = true
    }

    fileprivate func showViews() {
        for view in self.view.subviews {
            if let button = view as? UIButton {
                button.isHidden = false
            }
        }

        self.responseLabel.isHidden = false
    }

    @IBAction func signOutTapped(_ sender: UIBarButtonItem) {

        guard let title = sender.title, !title.isEmpty else {
            return
        }

        if title == "Sign-In" {
             self.showSignInUI()
        } else {

            AWSMobileClient.sharedInstance().signOut(options: .init(signOutGlobally: true,
                                                                    invalidateTokens: true)) { (error) in
                if error != nil {
                    print("Error: \(error!.localizedDescription)")
                } else {

                    print("Signed-Out now.")

                    DispatchQueue.main.async {
                        self.signInStateLabel.text = "Logged Out"
                        self.signOutBarButton.title = "Sign-In"
                        gCognitoToken = ""

                        self.hideViews()
                    }
                }
            }
        }
    }

}
