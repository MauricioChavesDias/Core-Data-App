//
//  InvoicesTableViewController.swift
//  Core Data App
//
//  Created by Mauricio Dias on 27/5/21.
//

import UIKit
import CoreData

class InvoicesTableViewController: UITableViewController {
    var invoicesFetchLocal: [InvoiceCoreData]?
    var selectedPurchaseOrder: PurchaseOrderCoreData?
    
    //Reference to manage object context
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fetchData()
    }

    //MARK: - TableView - Total number of items shown
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return invoicesFetchLocal?.count ?? 0
    }
    
    //MARK: - TableView - Data shown in each cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InvoiceCell", for: indexPath)
        let invoiceNumber = invoicesFetchLocal?[indexPath.row].invoice_number!.description ?? ""
        let receivedStatus = invoicesFetchLocal?[indexPath.row].received_status.description ?? ""
        cell.textLabel?.text = "Number: \(invoiceNumber)"
        cell.detailTextLabel?.text = "Status: \(receivedStatus)"
        return cell
    }
    
    //MARK: - CRUD - Fetch Data
    func fetchData(){
        do {
            let request = InvoiceCoreData.fetchRequest() as NSFetchRequest<InvoiceCoreData>
            let pred = NSPredicate(format: "purchase_order == %@", selectedPurchaseOrder!)
            request.predicate = pred
            self.invoicesFetchLocal = try context.fetch(request)
        } catch  {
            print("Unexpected error occured trying to retrieve items from core data, \(error)")
        }
        updateUITableView()
    }
    
    //MARK: - UpdateUI TableView
    func updateUITableView(){
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}
