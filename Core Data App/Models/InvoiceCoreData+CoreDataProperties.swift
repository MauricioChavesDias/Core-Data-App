//
//  InvoiceCoreData+CoreDataProperties.swift
//  Core Data App
//
//  Created by Mauricio Dias on 31/5/21.
//
//

import Foundation
import CoreData


extension InvoiceCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<InvoiceCoreData> {
        return NSFetchRequest<InvoiceCoreData>(entityName: "InvoiceCoreData")
    }

    @NSManaged public var id: Int64
    @NSManaged public var invoice_number: String?
    @NSManaged public var received_status: Int64
    @NSManaged public var purchase_order: PurchaseOrderCoreData?

}

extension InvoiceCoreData : Identifiable {

}
