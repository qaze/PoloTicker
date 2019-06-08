import UIKit

enum OrderType : String {
    case sell = "sell"
    case buy = "buy"
}

enum OrderStatus {
    case open, completed
}

class Order {
    let rate : Double
    let total : Double
    let amount : Double
    let type : OrderType
    var date : Date?
    let orderID : Int
    let status : OrderStatus
    
    
    init( orderID id: Int, rate r: Double, total t: Double, amount a: Double, type tp: OrderType, status s: OrderStatus ) {
        self.rate = r
        self.total = t
        self.amount = a
        self.type = tp
        self.orderID = id
        self.status = s
    }
}
