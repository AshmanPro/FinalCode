//
//  DetailViewController.swift
//  Collaborator
//  s5062234
//  Created by Ashman Malik on 2/5/18.
//  Copyright © 2018 Ashman Malik. All rights reserved.
//


import UIKit
import MultipeerConnectivity

// for sending data between Detail and Master Controller
protocol editTaskDelegate {
    func editTask(task: String, collaboration: String, log: [(String)])
}

// for sending data between detail and Chat controller
protocol updateChatDelegate {
    func chatText(chat:String, sender: Int)
}

class DetailViewController: UITableViewController, refreshDetailViewControllerDelegate, sendChatDelegate {
    
    //delegate declaration
    var delegate: editTaskDelegate? = nil
    var chatDelegate: updateChatDelegate?
    
    //declare variables
    var task = ""
    var log = [String]()
    var collaborators = [MCPeerID]()
    
    //Peer to Peer Managment Variable declaration
    let serviceType = "collab-list"
    var browser : MCNearbyServiceBrowser!
    var peerID: MCPeerID!
    var serviceAdvertiser: MCNearbyServiceAdvertiser!
    lazy var session: MCSession = {
        let session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        session.delegate = self
        return session
    }()
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail = detailItem {
            task = detail.task
            log = detail.log
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if detailItem == nil {
            // When ther is no data between Master and Detail, don't enable the TextFields in Table view
            guard let taskTextField = self.tableView.viewWithTag(1) as! UITextField? else { return }
            guard let logTextField = self.tableView.viewWithTag(2) as! UITextField? else { return }
            guard let collaboratorLabel = self.tableView.viewWithTag(3) as! UILabel? else { return }
            taskTextField.isEnabled = false
            logTextField.isEnabled = false
            collaboratorLabel.isEnabled = false
        }else{
            configureView()
            
            //Initialize peer to peer variables
            self.peerID = MCPeerID(displayName: "Omair Aslam")
            self.browser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
            self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: [ peerID.displayName : UIDevice.current.name ], serviceType: serviceType)
            
            // Start advertising to peers
            serviceAdvertiser.delegate = self
            serviceAdvertiser.startAdvertisingPeer()
            
            // Start browsing for peers
            browser.delegate = self
            browser.startBrowsingForPeers()
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //called from Master to update the Detail view on Segue
    var detailItem: colitem? {
        didSet {
            // Update the view.
            configureView()
        }
    }
    
    // This is to add new logs
    @IBAction func addNewLog(_ sender: Any) {
        let currentTime = getDateTime()
        let manualLog = currentTime + " Edit this Log"
        log.append(manualLog)
        tableView.reloadData()
    }
    // Used to edit the Task Name or Logs
    func editCollaborationItem(text: String, tag: Int, index: String) {
        var text = text
        if text == "" {
            text = "Edit this"
        }
        if delegate != nil {
            if(tag == 1){ // Editing the task name
                task = text
                let currentTime = getDateTime()
                let editlog = currentTime + " Omair Aslam changed topic to '" + task + "'"
                log.append(editlog)
                delegate?.editTask(task: text, collaboration: "", log: log)
                tableView.reloadData()
            }
            if(tag == 2){ // Editing the logs
                let indexToUpdate = Int(index)
                log[indexToUpdate!] = text
                delegate?.editTask(task: task, collaboration: "", log: log)
                tableView.reloadData()
            }
            
        }
    }
    
    // setting delegates on segue to Chat controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowChatBox" {
            let controller = (segue.destination as! UINavigationController).topViewController as! ChatMessageViewController
            controller.delegate = self // set the delegate of Chat controller to Detail
            controller.currentPeer = self.peerID.displayName // send peer name with segue
            controller.navTitle = self.task
            chatDelegate=controller // set the controller as delgate
        }
    }
    
    
    // Table View delegate methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(section == 0){
            return "TASK"
        }else if(section == 1){
            return "COLLABORATORS"
        }else{
            return "LOG"
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return 1
        }else if(section == 1){
            return collaborators.count
        }else{
            return log.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CollaboratorCell", for: indexPath)
        if(indexPath.section == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell", for: indexPath)
            guard let taskTextField = cell.viewWithTag(1),
                let taskField = taskTextField as? UITextField else {
                    print("in guard else")
                    return cell
            }
            taskField.text = task
            taskField.placeholder = "Task Name"
            return cell
        }
        if(indexPath.section == 1) {
            guard let collaboratorLabel = cell.viewWithTag(3),
                let collabField = collaboratorLabel as? UILabel else {
                    print("in guard else")
                    return cell
            }
            print(collaborators[indexPath.row].displayName)
            collabField.text = collaborators[indexPath.row].displayName
            return cell
        }
        if(indexPath.section == 2) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "LogCell", for: indexPath)
            guard let logTextField = cell.viewWithTag(2),
                let logField = logTextField as? UITextField else {
                    print("in guard else 2")
                    return cell
            }
            if log.isEmpty {
                logField.text = ""
            }else{
                logField.text = log[indexPath.row]
                logField.placeholder = String(indexPath.row)
            }
            return cell
        }
        return cell
    }
    
    // Delegate function called from Chat controller, to send a meesage through session
    func message(msg: String, chat:[String]) {
        let message = msg.data(using: String.Encoding.utf8,
                               allowLossyConversion: false)
        guard !session.connectedPeers.isEmpty else {
            return
        }
        do {
            try session.send(message!, toPeers: session.connectedPeers, with: MCSessionSendDataMode.unreliable)
        } catch {
            print("Error sending data")
        }
        self.updateLog(message: msg) // This will update the log
    }
    
    // Delegate function called from Master controller, to update the detail view if collaboration items are draged from "ONGOING" to "DONE"
    func refresh() {
        tableView.reloadData()
    }
    
    // Internal function that updates the logs with chat message of particular collaboration Item
    func updateLog(message: String){
        self.log.append(message)
        self.delegate?.editTask(task: self.task, collaboration: "", log: self.log)
        self.tableView.reloadData()
    }
    
    // Internal function called automatically as soon as a peer is found, invite send directly
    func invite(peer: MCPeerID, timeout t: TimeInterval = 10) {
        print("inviting \(peer.displayName)")
        browser.invitePeer(peer, to: session, withContext: nil, timeout: t)
        if !collaborators.contains(peerID){
            collaborators.append(peerID) // only adds to the list of collabrators if not exists before
        }
        tableView.reloadData()
    }
    
    // Internal function that gives a date time in a particular format to diaplay in logs, messages etc
    func getDateTime()-> String{
        let dateformatter = DateFormatter()
        dateformatter.dateStyle = DateFormatter.Style.short
        dateformatter.timeStyle = DateFormatter.Style.short
        let currentTime = dateformatter.string(from: NSDate() as Date)
        return currentTime
    }
}

// Delegate function for Text Field
extension DetailViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("detected enter button")
        editCollaborationItem(text: textField.text!, tag:textField.tag, index: textField.placeholder!)
        self.view.endEditing(true)
        return false
    }
}

// Delegate functions for browsing peers
extension DetailViewController: MCNearbyServiceBrowserDelegate{
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print("didNotStartBrowsingForPeers: \(error)")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("foundPeer: \(peerID) - \(info?.description ?? "<no info>")")
        invite(peer: peerID) // call internal function to send invite as soon a peer is found
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        print("lostPeer: \(peerID)")
    }
}

// Delegate function for Advertiser
extension DetailViewController: MCNearbyServiceAdvertiserDelegate{
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print("didNotStartAdvertisingPeer: \(error)")
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("didReceiveInvitationFromPeer \(peerID)")
        invitationHandler(true, session) // as soon as a invite request recieved, accept it automatically
    }
}

// Delegate function for Session
extension DetailViewController: MCSessionDelegate{
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        print("peer \(peerID) didChangeState: \(state)")
        
        //more of a test purpose, to check the current state of session
        OperationQueue.main.addOperation({
            switch (state) {
            case .connected:
                print("connected")
            case .connecting:
                break
            case .notConnected:
                print("not connected")
            }
        })
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("didReceiveData: \(data)")
        DispatchQueue.main.async {
            let message = NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue)
            self.chatDelegate?.chatText(chat: message! as String, sender: 1) //update the chat of connected peer with data
            self.updateLog(message: message! as String) // This will update the log of peer
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("didReceiveStream")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print("didStartReceivingResourceWithName")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        print("didFinishReceivingResourceWithName")
    }
}
