//
//  PurchaseOrderManager.swift
//  Core Data App
//
//  Created by Mauricio Dias on 24/5/21.
//  

import Foundation

protocol PurchaseOrderJSONManagerDelegate {
    func didUpdatePurchaseOrder(purchaseOrders: [PurchaseOrderModel]?)
    func didFailWithError(error : Error)
}

struct PurchaseOrderJSONManager {
    var purchaseOrdersList = [PurchaseOrderModel]()
    var session: URLSession
    let urlEndpoint = "https://my-json-server.typicode.com/butterfly-systems/sample-data/purchase_orders"
    var delegate: PurchaseOrderJSONManagerDelegate?
    
    init() {
        session = URLSession(configuration: .default)
    }
    
    mutating func fetchDataFromJSON(){
        self.performRequest(with: urlEndpoint)
    }
    
    
    // MARK: ParseJSON data
    func parseJSON(purchaseOrderData: Data) -> [PurchaseOrderModel]? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        var purchasesOrdersJSON = [PurchaseOrderModel]()
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode([PurchaseOrder].self, from: purchaseOrderData)
            for order in decodedData {
                let id           = order.id
                let last_updated = formatter.date(from: order.last_updated)!
                var items        = [ItemModel]()
                var invoices     = [InvoiceModel]()
                for item in order.items {
                    items.append(ItemModel(id: item.id,
                                           product_item_id: item.product_item_id,
                                           quantity: item.quantity))
                }
                for invoice in order.invoices {
                    invoices.append(InvoiceModel(id: invoice.id,
                                                 invoice_number: invoice.invoice_number,
                                                 received_status: invoice.received_status))
                }
                purchasesOrdersJSON.append(PurchaseOrderModel(id: id,
                                                              items: items,
                                                              invoices: invoices,
                                                              last_updated: last_updated))
            }
            return purchasesOrdersJSON
        } catch  {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    
    //MARK: - PerformRequest Endpoint
    func performRequest(with urlString: String) {
        if let safeURL = URL(string: urlString) {
            let task = session.dataTask(with: safeURL) {(data, response, error) in
                if error != nil {
                    return //exit
                }
                if let safeData = data {
                    if let safePurchaeOrdersList = self.parseJSON(purchaseOrderData: safeData) {
                        delegate?.didUpdatePurchaseOrder(purchaseOrders: safePurchaeOrdersList)
                    }
                }
            }
            task.resume()
        }
    }
}

