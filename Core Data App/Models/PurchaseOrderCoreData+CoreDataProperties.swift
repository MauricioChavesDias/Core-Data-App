//
//  PurchaseOrderCoreData+CoreDataProperties.swift
//  Core Data App
//
//  Created by Mauricio Dias on 31/5/21.
//
//

import Foundation
import CoreData


extension PurchaseOrderCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PurchaseOrderCoreData> {
        return NSFetchRequest<PurchaseOrderCoreData>(entityName: "PurchaseOrderCoreData")
    }

    @NSManaged public var id: Int64
    @NSManaged public var last_updated: Date?
    @NSManaged public var supplier_id: Int64
    @NSManaged public var invoices: NSSet?
    @NSManaged public var items: NSSet?

}

// MARK: Generated accessors for invoices
extension PurchaseOrderCoreData {

    @objc(addInvoicesObject:)
    @NSManaged public func addToInvoices(_ value: InvoiceCoreData)

    @objc(removeInvoicesObject:)
    @NSManaged public func removeFromInvoices(_ value: InvoiceCoreData)

    @objc(addInvoices:)
    @NSManaged public func addToInvoices(_ values: NSSet)

    @objc(removeInvoices:)
    @NSManaged public func removeFromInvoices(_ values: NSSet)

}

// MARK: Generated accessors for items
extension PurchaseOrderCoreData {

    @objc(addItemsObject:)
    @NSManaged public func addToItems(_ value: ItemCoreData)

    @objc(removeItemsObject:)
    @NSManaged public func removeFromItems(_ value: ItemCoreData)

    @objc(addItems:)
    @NSManaged public func addToItems(_ values: NSSet)

    @objc(removeItems:)
    @NSManaged public func removeFromItems(_ values: NSSet)

}

extension PurchaseOrderCoreData : Identifiable {

}
