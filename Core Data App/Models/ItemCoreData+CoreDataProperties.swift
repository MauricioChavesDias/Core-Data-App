//
//  ItemCoreData+CoreDataProperties.swift
//  Core Data App
//
//  Created by Mauricio Dias on 31/5/21.
//
//

import Foundation
import CoreData


extension ItemCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ItemCoreData> {
        return NSFetchRequest<ItemCoreData>(entityName: "ItemCoreData")
    }

    @NSManaged public var id: Int64
    @NSManaged public var quantity: Int64
    @NSManaged public var purchase_order: PurchaseOrderCoreData?

}

extension ItemCoreData : Identifiable {

}
