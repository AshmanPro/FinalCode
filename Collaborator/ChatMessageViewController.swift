//
//  DetailViewController.swift
//  Collaborator
//  s5062234
//  Created by Ashman Malik on 2/5/18.
//  Copyright © 2018 Ashman Malik. All rights reserved.
//

// Note For ChatMessageView Controller

   // I have used the Connect Button to Show Browser and Both Device should open the same screen to Get Peers and send an invite to peer. Once connected can send message using send button.
import UIKit
import MultipeerConnectivity

// for sending data between Chat and Detail controller
protocol sendChatDelegate {
    func message(msg: String, chat:[String])
}

class ChatMessageViewController: UIViewController, updateChatDelegate {

    
    
    // properties
    @IBOutlet weak var textFeildChat: UITextField!
    @IBOutlet weak var chatTableView: UITableView!
    
    //declare variables
    var chat = [String]()
    var currentPeer = ""
    var navTitle = ""
    
    //delegate declaration
    var delegate: sendChatDelegate? = nil
    
    
    // Internal function that updates the table view and also calls the delegate function in Detail
    func sendChat() {
        let currentTime = getDateTime()
        let message = currentTime + " " + currentPeer + " " + textFeildChat.text!
        chat.append(message)
        self.chatTableView.reloadData()
        delegate?.message(msg: message, chat: chat)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = navTitle
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Delegate function, updates the chat table view for connected peer
    func chatText(chat:String, sender: Int) {
        self.chat.append(chat)
        self.chatTableView.reloadData()
    }
    
    // Internal function that gives a date time in a particular format to diaplay in messages
    func getDateTime()-> String{
        let dateformatter = DateFormatter()
        dateformatter.dateStyle = DateFormatter.Style.short
        dateformatter.timeStyle = DateFormatter.Style.short
        let currentTime = dateformatter.string(from: NSDate() as Date)
        return currentTime
    }
}

// Delegate function for Text Field
extension ChatMessageViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendChat()
        self.view.endEditing(true)
        return false
    }
}

// Delegate functions for Table view
extension ChatMessageViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chat.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = chat[indexPath.row]
        cell.textLabel?.numberOfLines=0
        cell.textLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        if (indexPath.row % 2 == 0){
            cell.backgroundColor = UIColor(red: 0.67, green: 0.67, blue: 0.67, alpha: 1.0)
        }else{
            cell.backgroundColor = UIColor(red: 0.82, green: 0.90, blue: 0.99, alpha: 1.0)
        }
        return cell
    }
}
