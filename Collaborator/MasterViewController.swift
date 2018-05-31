//
//  MasterViewController.swift
//  Collaborator
//  s5062234
//  Created by Ashman Malik on 2/5/18.
//  Copyright © 2018 Ashman Malik. All rights reserved.
//


import UIKit

let sections = ["ONGOING", "DONE"]

// for refeshing the table view controller in Detail
protocol refreshDetailViewControllerDelegate {
    func refresh()
}


class MasterViewController: UITableViewController, editTaskDelegate {
    //delegate declaration
    var delegate: refreshDetailViewControllerDelegate? = nil
    
    //declare variables
    var detailViewController: DetailViewController? = nil
    var inProgressTask = colList().itemList // array for "On Going"  tasks
    var doneTask = colList().itemList // array for "Done"  tasks
    var count = 1 // This count is used later  to increment the addition of collaboration tasks
    var indexPathRow = -1 // Initialize and used later to keep track of row clicked
    var indexPathSection = -1 // Initialize and used later to keep track of section of row clicked
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = editButtonItem //This gives us delete and drag styling
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        navigationItem.rightBarButtonItem = addButton // button to add new items to list
        
        //for bigger screens, show side by side
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // This adds new Item to list of collaboration items
    @objc
    func insertNewObject(_ sender: Any) {
        let currentTime = getDateTime()
        let task = "Collaboration Point " + String(count)
        let collaboration = ""
        let log = currentTime + " Omair Aslam created '" + task + "'"
        let item = colitem(task: task, collaboration: collaboration, log: [log])
        inProgressTask.append(item)
        count = count + 1; // update count for next entry of items
        tableView.reloadData()
    }
    
    // setting delegates on segue to Detail controller, sending data and setting indexPathRow and IndexPathSection
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                if(indexPath.section) == 0 {
                    let object = inProgressTask[indexPath.row]
                    controller.detailItem = object
                    indexPathRow = indexPath.row
                    indexPathSection = 0
                } else {
                    let object = doneTask[indexPath.row]
                    controller.detailItem = object
                    indexPathRow = indexPath.row
                    indexPathSection = 1
                }
                controller.delegate = self // set the delegate of Detail controller to Master
                delegate = controller // set delegate as controller
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
            
        }
    }
    
    // Table View delegate methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return inProgressTask.count
        }else if(section == 1){
            return doneTask.count
        }else{
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        if indexPath.section == 0 {
            cell.textLabel!.text = inProgressTask[indexPath.row].task
        } else if(indexPath.section == 1){
            cell.textLabel!.text = doneTask[indexPath.row].task
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if (indexPath.section == 0) {
                inProgressTask.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            else if (indexPath.section == 1) {
                doneTask.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
    }
    
    // This handles smartly the drag and drop between "ONGOING" and "DONE", updates the relevent arrays
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if (sourceIndexPath.section == 0) {
            let item = inProgressTask[sourceIndexPath.row]
            if(destinationIndexPath.section == 1){ // This loop if section changes
                let currDateTime = getDateTime()
                let editlog = currDateTime + " Omair Aslam moved " + inProgressTask[sourceIndexPath.row].task + " from ONGOING to DONE"
                inProgressTask[sourceIndexPath.row].log.append(editlog)
                
                doneTask.insert(item, at: destinationIndexPath.row)
                inProgressTask.remove(at: sourceIndexPath.row)
                
                delegate?.refresh() // This refeshes the table view in Detail to show changes
            } else if(destinationIndexPath.section == 0){ // This loop if swap is in same section
                inProgressTask.swapAt(sourceIndexPath.row, destinationIndexPath.row)
            }
        } else if (sourceIndexPath.section == 1){
            let item = doneTask[sourceIndexPath.row]
            if(destinationIndexPath.section == 0){ // This loop if section changes
                let currDateTime = getDateTime()
                let editlog = currDateTime + " Omair Aslam moved " + doneTask[sourceIndexPath.row].task + " from DONE to ONGOING"
                inProgressTask[sourceIndexPath.row].log.append(editlog)
                
                inProgressTask.insert(item, at: destinationIndexPath.row)
                doneTask.remove(at: sourceIndexPath.row)
                
                delegate?.refresh() // This refeshes the table view in Detail to show changes
            } else if(destinationIndexPath.section == 1){ // This loop if swap is in same section
                doneTask.swapAt(sourceIndexPath.row, destinationIndexPath.row)
            }
        }
        tableView.reloadData()
    }
    
    // delegate function called, when updating the task name or logs in Detail, this updates the complete array
    func editTask(task: String, collaboration: String, log: [(String)]) {
        let item = colitem(task: task, collaboration: collaboration, log: log)
        if(indexPathSection == 0){
            inProgressTask[indexPathRow] = item
        }else if(indexPathSection == 1){
            doneTask[indexPathRow] = item
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

