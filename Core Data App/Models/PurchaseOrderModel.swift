//
//  PurchaseOrderModel.swift
//  Core Data App
//
//  Created by Mauricio Dias on 24/5/21.
//

import Foundation

struct PurchaseOrderModel {
    let id: Int
    var items: [ItemModel]
    var invoices: [InvoiceModel]
    var last_updated: Date
}
