//
//  ItemsTableViewController.swift
//  Core Data App
//
//  Created by Mauricio Dias on 25/5/21.
//

import UIKit
import CoreData

//protocol responsible to alert PurchaseOrderTableViewC to update its screen
protocol ItemsTableViewControllerDelegate {
    func didUpdateItem()
}

class ItemsTableViewController: UITableViewController {
    var itemsFetch: [ItemCoreData]?
    var selectedPurchaseOrder: PurchaseOrderCoreData?
    var delegate: ItemsTableViewControllerDelegate?
    var purchaseOrderID: String?
    
    //Reference to manage object context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UINib(nibName: "ItemTableViewCell", bundle: nil), forCellReuseIdentifier: "ItemCell")
        fetchData()
        updateUITableView()
    }
    
    
    //MARK: IBAction - Add a new purchase order
    @IBAction func addNewItemButtonPressed(_ sender: UIBarButtonItem) {
        let alert = createAlertUI()
        self.present(alert, animated: true, completion: nil)
    }

    //MARK: - Create the alert UI to insert or edit the item
    func createAlertUI(editing: Bool = false, indexItemSelected: Int = 0) -> UIAlertController {
        var idTextField = UITextField()
        var quantityTextField = UITextField()
        let alertDescription     = editing ? "Edit Item" : "Add New Item"
        let idItemSelected       = editing ? self.itemsFetch![indexItemSelected].id.description : ""
        let quantityItemSelected = editing ? self.itemsFetch![indexItemSelected].quantity.description : ""

        let alert = UIAlertController(title: alertDescription, message: "", preferredStyle: .alert)
        let addButton = UIAlertAction(title: "Add", style: .cancel) { (action) in
            let newItem: ItemCoreData
            if editing {
                newItem = self.itemsFetch![indexItemSelected]
            } else {
                newItem = ItemCoreData(context: self.context)
            }
            newItem.id = Int64(idTextField.text!) ?? 0
            newItem.quantity = Int64(quantityTextField.text!) ?? 0
            self.selectedPurchaseOrder?.last_updated = Date()
            self.selectedPurchaseOrder?.addToItems(newItem)
            self.delegate?.didUpdateItem()
            self.fetchData()
            self.updateUITableView()
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action: UIAlertAction!) in
            alert.dismiss(animated: true, completion: nil)
        })
        //set to accept only numbers
        alert.addTextField { (alertTextField) in
            alertTextField.keyboardType = .numberPad
            alertTextField.placeholder = "ID here"
            alertTextField.text = idItemSelected
            idTextField = alertTextField
        }
        alert.addTextField { (alertTextField) in
            alertTextField.keyboardType = .numberPad
            alertTextField.placeholder = "Quantity"
            alertTextField.text = quantityItemSelected
            quantityTextField = alertTextField
        }
        alert.addAction(addButton)
        alert.addAction(cancelButton)
        return alert
    }
    
    //MARK: - PerformSEGUE to InvoicesTableViewController
    @IBAction func viewInvoicesButtonPressed(_ sender: UIBarButtonItem) {
        ///SEQUE TO INVOICE VC
        if selectedPurchaseOrder?.invoices?.count ?? 0 > 0 {
            self.performSegue(withIdentifier: "goToInvoicesTableVC", sender: self)
        } else {
            let alert = UIAlertController(title: "Whoops!", message: "There's no invoices for this purchase order", preferredStyle: .alert)
            let buttonOK = UIAlertAction(title: "Ok", style: .cancel) { (action) in
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(buttonOK)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    //MARK: - UpdateUI TableView
    func updateUITableView(){
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    //MARK: - CRUD - Fetch Data
    func fetchData(){
        do {
            let request = ItemCoreData.fetchRequest() as NSFetchRequest<ItemCoreData>
            let pred = NSPredicate(format: "purchase_order == %@", selectedPurchaseOrder!)
            request.predicate = pred
            self.itemsFetch = try context.fetch(request)
        } catch  {
            print("Unexpected error occured trying to retrieve items from core data, \(error)")
        }
        updateUITableView()
    }
    //MARK: - TableView - Total number of items shown
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsFetch!.count
    }

    //MARK: - TableView - Data shown in each cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemTableViewCell
        cell.itemIDLabel.text = itemsFetch?[indexPath.row].id.description
        cell.quantityLabel.text = itemsFetch?[indexPath.row].quantity.description
        return cell
    }
    
    //MARK: - TableView - Action when the cell is swiped
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { action, view, completionHandler in
            // Deletes purchase order
            let itemToDelete = self.itemsFetch![indexPath.row]
            self.context.delete(itemToDelete)
            self.selectedPurchaseOrder?.removeFromItems(itemToDelete)
            self.delegate?.didUpdateItem()
            self.fetchData()
        }
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    //MARK: - TableView - Action when the cell is selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = createAlertUI(editing: true, indexItemSelected: indexPath.row)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - Navigation to InvoiceTableViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToInvoicesTableVC" {
            let invoicesTableViewController = segue.destination as! InvoicesTableViewController
            invoicesTableViewController.selectedPurchaseOrder = selectedPurchaseOrder
        }
    }

}
