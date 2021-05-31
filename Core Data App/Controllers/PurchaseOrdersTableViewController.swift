//
//  ViewController.swift
//  Core Data App
//
//  Created by Mauricio Dias on 24/5/21.
//

import UIKit
import CoreData

class PurchaseOrdersTableViewController: UITableViewController {
    var dataJSON = PurchaseOrderJSONManager()
    var purchaseOrdersFetchJSON: [PurchaseOrderModel]?
    var purchaseOrdersFetch: [PurchaseOrderCoreData]?
    var purchaseOrderFetch: [PurchaseOrderCoreData]?
    var lastUpdatedPOLocal: Date?
    var indexPurchaseOrderSelected: Int = 0
    
    
    //Reference to manage object context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "PurchaseOrderTableViewCell", bundle: nil), forCellReuseIdentifier: "purchaseOrderCell")
        dataJSON.delegate = self
        configureRefreshControl()
        dataJSON.fetchDataFromJSON()
        fetchData()
    }

    //MARK: - Configuration of the RefreshControl to TableView
    func configureRefreshControl () {
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.tintColor = .orange
        tableView.refreshControl?.addTarget(self, action:
                                                #selector(handleRefreshControl),
                                                for: .valueChanged)
    }
    
    @objc func handleRefreshControl() {
        tableView.refreshControl?.beginRefreshing()
        self.syncDataWithTheServer()
        tableView.refreshControl?.endRefreshing()

    }

    //MARK: IBAction - Add a new purchase order
    @IBAction func addNewPurchaseOrderButtonPressed(_ sender: UIBarButtonItem) {
        //Create a basic alert to add a new purchase order
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Purchase Order", message: "Order ID", preferredStyle: .alert)
        let submitButton = UIAlertAction(title: "Add", style: .cancel) { (action) in
            let newPurchaseOrder = PurchaseOrderCoreData(context: self.context)
            newPurchaseOrder.id = Int64(textField.text!) ?? 0
            newPurchaseOrder.last_updated = Date()
            newPurchaseOrder.supplier_id = Int64(textField.text!) ?? 0
            self.saveDataToCoreData()
            self.fetchData()
        }
        let cancelButton = UIAlertAction(title: "Cancel", style: .destructive, handler: { (action: UIAlertAction!) in
            alert.dismiss(animated: true, completion: nil)
        })
        alert.addTextField { (alertTextField) in
            alertTextField.keyboardType = .numberPad
            alertTextField.placeholder = "Enter Order ID"
            textField = alertTextField
        }
        alert.addAction(submitButton)
        alert.addAction(cancelButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - CRUD - Save the data
    func saveDataToCoreData() {
        do {
            try self.context.save()
        } catch  {
            print("Error saving the data to Core Data, \(error)")
        }
    }
    
    //MARK: - CRUD - Fetch Data from the server and then local
    func fetchData(){
        do {
            let request = PurchaseOrderCoreData.fetchRequest() as NSFetchRequest<PurchaseOrderCoreData>
            let sort = NSSortDescriptor(key: "last_updated", ascending: true)
            request.sortDescriptors = [sort]
            purchaseOrdersFetch = try context.fetch(request)
            lastUpdatedPOLocal = purchaseOrdersFetch?.last?.last_updated ?? Date(timeIntervalSince1970: 0)
            updateUITableView()
        } catch  {
            print("Unexpected error occured trying to retrieve purchase orders from core data, \(error)")
        }
    }
    
    //MARK: - CRUD - Fetch Data from the server and then local
    func findPurchaseOrder(purchase orderID: Int64) -> [PurchaseOrderCoreData]? {
        do {
            let request = PurchaseOrderCoreData.fetchRequest() as NSFetchRequest<PurchaseOrderCoreData>
            let pred = NSPredicate(format: "id == %@", orderID.description)
            request.predicate = pred
            purchaseOrderFetch = try context.fetch(request)
        } catch  {
            print("Unexpected error occured trying to find a purchase order, \(error)")
        }
        return purchaseOrderFetch
    }
    
    
    //MARK: - Sync data with the server
    func syncDataWithTheServer() {
        var purchaseOrderModifiedInServer = false
        if let safePurchaseOrderJSON = purchaseOrdersFetchJSON {
            for order in safePurchaseOrderJSON {
                //Override an existent purchase order in case it was modified in the server.
                if let index = purchaseOrdersFetch?.firstIndex(where: {$0.id == 1}) {
                    purchaseOrderModifiedInServer = order.last_updated > purchaseOrdersFetch![index].last_updated ?? Date(timeIntervalSince1970: 0)
                    if  purchaseOrderModifiedInServer {
                        self.context.delete(purchaseOrdersFetch![index])
                        let newPurchaseOrder = PurchaseOrderCoreData(context: self.context)
                        newPurchaseOrder.id = Int64(order.id)
                        newPurchaseOrder.last_updated = order.last_updated
                        for item in order.items {
                            let newItem = ItemCoreData(context: self.context)
                            newItem.id = Int64(item.id)
                            newItem.quantity = Int64(item.quantity)
                            newPurchaseOrder.addToItems(newItem)
                        }
                        for invoice in order.invoices {
                            let newInvoice = InvoiceCoreData(context: self.context)
                            newInvoice.id = Int64(invoice.id)
                            newInvoice.invoice_number = invoice.invoice_number
                            newInvoice.received_status = Int64(invoice.received_status)
                            newPurchaseOrder.addToInvoices(newInvoice)
                        }
                    }
                } else {
                    //ADD a new purchase order in case it was ADDED a new one in the server
                    let newPurchaseOrder = PurchaseOrderCoreData(context: self.context)
                    newPurchaseOrder.id = Int64(order.id)
                    newPurchaseOrder.last_updated = order.last_updated
                    for item in order.items {
                        let newItem = ItemCoreData(context: self.context)
                        newItem.id = Int64(item.id)
                        newItem.quantity = Int64(item.quantity)
                        newPurchaseOrder.addToItems(newItem)
                    }
                    for invoice in order.invoices {
                        let newInvoice = InvoiceCoreData(context: self.context)
                        newInvoice.id = Int64(invoice.id)
                        newInvoice.invoice_number = invoice.invoice_number
                        newInvoice.received_status = Int64(invoice.received_status)
                        newPurchaseOrder.addToInvoices(newInvoice)
                    }
                }
            }
            saveDataToCoreData()
            fetchData()
            updateUITableView()
        }
    }
    
    func getDateFormatted(from date: Date) -> String {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "dd/MM/yyyy hh:MM:SS"
        return dateFormat.string(from: date)
    }
    
    //MARK: - UpdateUI TableView
    func updateUITableView(){
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    //MARK: - Navigation to ItemsTableViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToItemsTableVC" {
            let itemsTableViewController = segue.destination as! ItemsTableViewController
            itemsTableViewController.selectedPurchaseOrder = purchaseOrdersFetch![indexPurchaseOrderSelected]
            itemsTableViewController.delegate = self
        }
    }
    
    //MARK: - TableView - Total number of items shown
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return purchaseOrdersFetch?.count ?? 0
    }
    
    //MARK: - TableView - Data shown in each cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "purchaseOrderCell", for: indexPath) as! PurchaseOrderTableViewCell
        let purchaseOrderObject = purchaseOrdersFetch![indexPath.row]
        cell.orderIDLabel.text = purchaseOrderObject.id.description
        cell.lastUpdatedDateLabel.text = getDateFormatted(from: purchaseOrderObject.last_updated!)
        cell.quantityLabel.text = purchaseOrderObject.items?.count.description
        return cell
    }
    
    //MARK: - TableView - Action when the cell is selected
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ///    SEGUE TO ITEMS TABLE VIEW
        indexPurchaseOrderSelected = indexPath.row
        self.performSegue(withIdentifier: "goToItemsTableVC", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    //MARK: - TableView - Action when the cell is swiped
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { action, view, completionHandler in
            // Deletes purchase order
            let purchaseOrderToDelete = self.purchaseOrdersFetch![indexPath.row]
            self.context.delete(purchaseOrderToDelete)
            self.saveDataToCoreData()
            self.fetchData()
        }
        //return swipe actions
        return UISwipeActionsConfiguration(actions: [action])
    }
}

//MARK: - PurchaseOrderJSONManagerDelegate - Protocol responsible to load JSON data
extension PurchaseOrdersTableViewController: PurchaseOrderJSONManagerDelegate {
    func didUpdatePurchaseOrder(purchaseOrders: [PurchaseOrderModel]?) {
        purchaseOrdersFetchJSON = purchaseOrders
        syncDataWithTheServer()
    }
    func didFailWithError(error: Error) {
        print("Failed trying to fetch JSON, error: \(error)")
    }
    
}

extension PurchaseOrdersTableViewController: ItemsTableViewControllerDelegate {
    func didUpdateItem() {
        self.saveDataToCoreData()
        self.fetchData()
        self.updateUITableView()
    }
    
}

