//
//  ViewController.swift
//  Peer2
//
//  Created by Rolando ArturoX May Alvarez on 18/09/20.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController, UINavigationControllerDelegate, MCSessionDelegate, MCBrowserViewControllerDelegate, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate{
    
    
    
    var peerID: MCPeerID!
    var mcSession: MCSession!
    var mcAdvertiserAssistant: MCNearbyServiceAdvertiser?
    var advertiser: MCNearbyServiceAdvertiser!
    
    var receiveMessage:String!
    var sendMessage:String!
    var hosting:Bool!
    var serviceBrowser : MCNearbyServiceBrowser!
    

    @IBOutlet weak var chatTextView: UITextView!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var SendButton: UIButton!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        peerID = MCPeerID(displayName: UIDevice.current.name)
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession.delegate = self
        if peerID.displayName == "iPhone 8"{
            startHosting()
        }
        else{
            clearButtonAction()
        }
        //startHosting()
        //senButton.isEnabled = false
        //chatTextView.isEditable = false
        //hosting = false
        //mcSession.disconnect()
        chatTextView.text = ""
        chatTextView.layer.borderColor = UIColor.lightGray.cgColor
        chatTextView.layer.borderWidth = 1
        
        // Creating a gesture to remove the keyboard
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.removeKeyBoard(_:)))
//        print(foundPeers)
        view.addGestureRecognizer(tap)
  
    }
    
    @objc func removeKeyBoard(_ sender: UITapGestureRecognizer){
        view.endEditing(true)
    }
    
    func clearButtonAction() {
//        chatTextView.text = ""
        //print("Start Brow")
        self.serviceBrowser = MCNearbyServiceBrowser(peer: peerID, serviceType: "hws-project25")
        self.serviceBrowser.delegate = self
        self.serviceBrowser.startBrowsingForPeers()
        //print("Finish browsing")
        
    }
    @IBAction func pressingSendButton(_ sender: Any) {
        sendMessage = "\n\(peerID.displayName): \(inputTextField.text!)\n"
        sendText(sendMsg: sendMessage)
    }
    

    func startHosting() {
        advertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: "hws-project25")
        advertiser.delegate = self
        advertiser.startAdvertisingPeer()
//        mcAdvertiserAssistant = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: "hws-project25")
//        mcAdvertiserAssistant?.startAdvertisingPeer()
    }

    func joinSession() {
        let mcBrowser = MCBrowserViewController(serviceType: "hws-project25", session: mcSession)
        mcBrowser.delegate = self
        present(mcBrowser, animated: true)
        print(mcBrowser)
    }
    

    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {

    }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {

    }

    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {

    }

    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }

    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
            print("****************** Connected: \(peerID.displayName)")

        case MCSessionState.connecting:
            print("***********Connecting: \(peerID.displayName)")

        case MCSessionState.notConnected:
            print("******************Not Connected: \(peerID.displayName)")
        }
    }

    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print(data)

            DispatchQueue.main.async {
                self.receiveMessage = NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue)! as String
                self.chatTextView.text! = ("\(self.chatTextView.text!)\n\(self.receiveMessage!)")
    }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("FoundPeer: \(peerID)")
        print("Peer Name: \(peerID.displayName)")
        if peerID.displayName == "iPhone 8"{
            print("True")
            browser.invitePeer(peerID, to: self.mcSession, withContext: nil, timeout: 10)
            print("Aqui")
            
        }
//        browser.invitePeer(peerID, to: self.mcSession, withContext: nil, timeout: 10)
        
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        
    }

    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print(peerID.displayName)
            invitationHandler(true, mcSession)
        }
    
    func sendText(sendMsg: String){

        let message = sendMsg.data(using: String.Encoding.utf8, allowLossyConversion: false)
        do {
            try mcSession.send(message!, toPeers: mcSession.connectedPeers, with: .reliable)
        }catch let error as NSError {
            let ac = UIAlertController(title: "Send error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
        
        chatTextView.text! = ("\(chatTextView.text!)\nMe:\(inputTextField.text!)\n")

    }
    
    
}
