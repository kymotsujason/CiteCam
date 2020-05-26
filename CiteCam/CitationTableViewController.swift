//
//  CitationTableViewController.swift
//  CiteCam
//
//  This is file that handles all activity on the main screen (first screen after launch screen).
//  Any updates to the list of citations are reflected here.
//  We can also export all of the citations on the list.
//
//  Main functions:
//  Display citations and photos in orderly manner.
//  Pull down to refresh.
//  Update/Refresh list of citations on returning to this screen.
//  Delete citations from the list.
//  Store citations to file.
//  Export all citations to email.
//
//  Created by Jason Yue 11/17/16
//


import UIKit
import MessageUI
import SCLAlertView

class CitationTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    
    // Variables.
    static var citations = [Citation]()
    static var isbn = [ISBN]()
    
    
    // On load.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Use the edit button item provided by the table view controller.
        navigationItem.leftBarButtonItem = editButtonItem
        // Load any saved citations.b
        if let savedCitations = loadCitations() {
            CitationTableViewController.citations += savedCitations
        }
        
        // Load any saved isbns.
        if let savedISBN = loadISBN() {
            CitationTableViewController.isbn += savedISBN
            let numOfISBN = CitationTableViewController.isbn.count
            
            // Ensure there are ISBN that hasn't been loaded, protect from out of range errors.
            if (numOfISBN > 0) {
                for element in 0...numOfISBN-1 {
                    GoogleBookService.checkInternet(isbn: CitationTableViewController.isbn[element].isbn)
                }
                
                // Notify user on success.
                if(CitationTableViewController.isbn.count <= 1) {
                    SCLAlertView().showSuccess("Offline ISBNs Translated!", subTitle: "All ISBNs stored during internet outage have been successfully converted to citations! Pull to refresh.", closeButtonTitle: "Okay!", duration: 6, colorStyle: 0xA429FF, colorTextButton: 0xFFFFFF)
                }
            }
            
            
            // Update list with crossfade animation.
            UIView.transition(with: tableView, duration: 0.35, options: .transitionCrossDissolve, animations: { () -> Void in
                self.tableView.reloadData()
            },
                              completion: nil);
            
            // Save changes to file.
            saveISBN()
        }
    }
    
    // Update list with crossfade animation whenever we go to this screen.
    override func viewDidAppear(_ animated: Bool) {
        UIView.transition(with: tableView, duration: 0.35, options: .transitionCrossDissolve, animations: { () -> Void in
            self.tableView.reloadData()
        },
                          completion: nil);
    }
    
    // Static function for adding a citation.
    static func addCitation(name: String, photo: UIImage) {
        let cite = Citation(name: name, photo: photo)!
        
        // Update citation list.
        citations.append(cite)
        
        // Save changes to file.
        saveCitation()
    }
    
    // Static function for adding an ISBN if internet access is denied.
    static func addISBN(code: String) {
        let isbnObj = ISBN(isbn: code)!
        
        // Update ISBN list.
        isbn.append(isbnObj)
        
        // Save changes to file.
        saveISBN()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Following functions are for proper initialization of the citation table view.
    
    // Number of sections.
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Number of rows.
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CitationTableViewController.citations.count
    }
    
    // Returns the information within a row (citation and photo).
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "CitationTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! CitationTableViewCell
        
        // Fetches the appropriate citation for the data source layout.
        let citation = CitationTableViewController.citations[indexPath.row]
        
        cell.nameLabel.text = citation.name
        cell.photoImageView.image = citation.photo
        
        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source.
            CitationTableViewController.citations.remove(at: indexPath.row)
            saveCitations()
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    
    /*
     // Override to support rearranging the table view.
     override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    // Following functions are for when the user clicks on a citation.
    
    // Prepare the citation information for editing.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            let CitationDetailViewController = segue.destination as! CitationViewController
            
            // Get the cell that generated this segue.
            // This will get the information of the cell.
            if let selectedCitationCell = sender as? CitationTableViewCell {
                let indexPath = tableView.indexPath(for: selectedCitationCell)!
                let selectedCitation = CitationTableViewController.citations[indexPath.row]
                CitationDetailViewController.citation = selectedCitation
            }
        }
    }
    
    // After user has finished editing the file and has either clicked "Cancel" or "Save".
    @IBAction func unwindToCitationList(_ sender: UIStoryboardSegue) {
        
        // Update cell row
        if let sourceViewController = sender.source as? CitationViewController, let citation = sourceViewController.citation {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                
                // Update an existing citation.
                CitationTableViewController.citations[selectedIndexPath.row] = citation
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            } else {
                
                // Add a new citation.
                let newIndexPath = IndexPath(row: CitationTableViewController.citations.count, section: 0)
                CitationTableViewController.citations.append(citation)
                tableView.insertRows(at: [newIndexPath], with: .bottom)
            }
            // Save the citations.
            saveCitations()
        }
    }
    
    // Pull to refresh functionality.
    @IBAction func refresh(_ sender: Any) {
        UIView.transition(with: tableView, duration: 0.35, options: .transitionCrossDissolve, animations: { () -> Void in
            self.tableView.reloadData()
        },
                          completion: nil);
        self.refreshControl?.endRefreshing()
    }
    
    // Following functions are for file storage interactions.
    
    // Save to file function.
    func saveCitations() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(CitationTableViewController.citations, toFile: Citation.ArchiveURL.path)
        if !isSuccessfulSave {
            print("Failed to save citations...")
        }
    }
    
    // Save to file function.
    func saveISBN() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(CitationTableViewController.isbn, toFile: ISBN.ArchiveURL.path)
        if !isSuccessfulSave {
            print("Failed to save citations...")
        }
    }
    
    // Static save function for compatibility.
    static func saveCitation() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(CitationTableViewController.citations, toFile: Citation.ArchiveURL.path)
        if !isSuccessfulSave {
            print("Failed to save citations...")
        }
    }
    
    // Static save function for compatibility.
    static func saveISBN() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(CitationTableViewController.isbn, toFile: ISBN.ArchiveURL.path)
        if !isSuccessfulSave {
            print("Failed to save citations...")
        }
    }
    
    // Load from file function.
    func loadCitations() -> [Citation]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Citation.ArchiveURL.path) as? [Citation]
    }
    
    // Load from file function.
    func loadISBN() -> [ISBN]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: ISBN.ArchiveURL.path) as? [ISBN]
    }
    
    // Email function activated by clicking "Export All" button.
    @IBAction func ExportAllButton(_ sender: UIButton) {
        // Check if device can send Email.
        if(MFMailComposeViewController.canSendMail()) {
            
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            
            
            // Set email destination and subject
            mailComposer.setToRecipients(["youremail@something.com"])
            mailComposer.setSubject("CiteCam citation delivered!")
            
            // Retrieve all citations.
            var citationMessage = ""
            if(CitationTableViewController.citations.count > 0) {
                for i in 0...(CitationTableViewController.citations.count - 1) {
                    // Fetches the appropriate citation for the data source layout.
                    let citation = CitationTableViewController.citations[i]
                    citationMessage += "\(citation.name)</br>"
                    
                }
            }
            
            // Set the message to the list of all citations and present the email form to user.
            mailComposer.setMessageBody(citationMessage, isHTML: true)
            present(mailComposer, animated: true, completion: nil)
            
        } else {
            
            // If there is no email functionality, display message.
            // Usually occurs if there really is no email function or that it is not set up.
            SCLAlertView().showError("Unable to Email!", subTitle: "We could not open the email client! Do you have the email client setup?")
        }
    }
    
    // Delegate to catch mail interactions.
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
}
