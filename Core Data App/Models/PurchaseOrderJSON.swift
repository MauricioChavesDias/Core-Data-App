//
//  PurchaseOrder.swift
//  Core Data App
//
//  Created by Mauricio Dias on 24/5/21.
//
// Structure JSON

import Foundation

struct PurchaseOrder: Codable {
    let id: Int
    let supplier_id: Int
    let purchase_order_number: String
    let stock_purchase_process_ids: [Int]
    let issue_date: String
    var items: [Item]
    var invoices: [Invoice]
    var cancellations: [Cancellation]
    var status: Int
    var active_flag: Bool
    var last_updated: String
    var last_updated_user_entity_id: Int
    var sent_date: String
    var server_timestamp: Int
    var device_key: String
    var approval_status: Int
    var preferred_delivery_date: String
    var delivery_note: String
}

struct Item: Codable {
    let id: Int
    let product_item_id: Int
    var quantity: Int
    var last_updated_user_entity_id: Int
    var transient_identifier: String
    var active_flag: Bool
    var last_updated: String
}

struct Invoice: Codable {
    let id: Int
    let invoice_number: String
    var received_status: Int
    let created: String
    var last_updated_user_entity_id: Int
    var transient_identifier: String
    var receipts: [Receipt]
    var receipt_sent_date: String
    var active_flag: Bool
    var last_updated: String
}

struct Receipt:Codable {
    let id: Int
    let product_item_id: Int
    var received_quantity: Int
    let created: String
    var last_updated_user_entity_id: Int
    var transient_identifier: String
    var sent_date: String
    var active_flag: Bool
    var last_updated: String
}

struct Cancellation: Codable {
    let id: Int
    let product_item_id: Int
    var ordered_quantity: Int
    var last_updated_user_entity_id: Int
    var created: String
    var transient_identifier: String
}
