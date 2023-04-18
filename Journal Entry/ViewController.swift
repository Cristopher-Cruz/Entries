//
//  ViewController.swift
//  Journal Entry
//
//  Created by christopher cruz on 4/17/23.
//

import UIKit

// MARK: - UIViewController
class ViewController: UIViewController {
    
    @IBOutlet var newButton: UIBarButtonItem!
    @IBOutlet var editButton: UIBarButtonItem!
    @IBOutlet var tableView: UITableView!
    var doneButton : UIBarButtonItem?   // button for edit state
    // Property observer : saveEntries will perform transformation from struct objects to map objects
    var entries = [Entry](){
        didSet{
            self.saveEntries()
        }
    }
    
    // MARK: viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTap))
        self.doneButton?.tintColor = .darkGray
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.loadEntries() // load data from UserDefaults --> defined below
    }
    
     // MARK: Done tapped : set button & TV back to original non-editing state
     @objc func doneButtonTap(){
         self.navigationItem.rightBarButtonItem = self.editButton
         self.tableView.setEditing(false, animated: true)
     }
    
    // MARK: New entry button tapped
    @IBAction func newTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Whats on your mind ?", message: nil, preferredStyle: .alert)
        let registerButton = UIAlertAction(title: "Ok", style: .default, handler: { [weak self]_ in
            guard let title = alert.textFields?[0].text else { return }
            let entry = Entry(title: title, done: false)
            self?.entries.append(entry)  // when entries is updated --> will call property observer
            self?.tableView.reloadData() // update TV to reflect changes made to DataSource
        })
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelButton)
        alert.addAction(registerButton)
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Enter your entry"
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: Edit button tapped
    @IBAction func editTapped(_ sender: Any) {
        guard !self.entries.isEmpty else { return }
        self.navigationItem.rightBarButtonItem = doneButton
        self.tableView.setEditing(true, animated: true)
    }
    
    // MARK: Save entries with UserDefaults
    func saveEntries (){
        let data = self.entries.map{
            [
                "title": $0.title,
                "done": $0.done
            ] as [String: Any]
        }
        let userDefaults = UserDefaults.standard
        userDefaults.set(data, forKey: "entries")
    }
    
    // MARK: Load entries from UserDefaults
    func loadEntries() {
        let userDefaults = UserDefaults.standard
        guard let data = userDefaults.object(forKey: "entries") as? [[String: Any]] else { return }
        self.entries = data.compactMap {
            guard let title = $0["title"] as? String else {return nil}
            guard let done = $0["done"] as? Bool else {return nil}
            return Entry(title: title, done: done)
        }
    }

}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.entries.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let entry = self.entries[indexPath.row]
        cell.textLabel?.text = entry.title
        
        if entry.done {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Entries"
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        self.entries.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        if self.entries.isEmpty {
            self.doneButtonTap() // exit edit state when all cells are deleted
        }
    }
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        var entries = self.entries
        // to move array in same order cells were moved
        let entry = entries[sourceIndexPath.row]
        entries.remove(at: sourceIndexPath.row) // delete original to do
        entries.insert(entry, at: destinationIndexPath.row)
        self.entries = entries // pass rearranged array
    }
}

// MARK: - UITableViewDelegate
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var entry = self.entries[indexPath.row]
        entry.done = !entry.done // toggle (T to F or F to T)
        self.entries[indexPath.row] = entry // store back in the array
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
}



