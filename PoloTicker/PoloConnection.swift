import UIKit
import Alamofire
import CryptoSwift

class PoloConnection {
    
    let sekretKey: String = "PUT_YOUR_SECRET_KEY_HERE";
    let apiKey: String = "PUT_API_KEY_HERE";
    
    func fetchTickers( callback: @escaping (DataResponse<Any>) -> Void ) -> Void {
        Alamofire.request("https://poloniex.com/public?command=returnTicker", method: .get).responseJSON { response in
            callback(response);
        };   
    }
    
    func tradingApiRequest( command: String, parameters: Parameters,  callback: @escaping (DataResponse<Any>) -> Void ){
        let timeInterval = NSDate().timeIntervalSince1970
        let nonceTime = String(Int(floor(timeInterval * 1000)))
        
        do{
            var pars : Parameters = ["nonce": nonceTime, "command": command]
            pars.merge(parameters) { first, second -> Any in
                return first
            }
            
            var query = [URLQueryItem]()
            
            for (par, val) in pars {
                query.append(URLQueryItem(name: par, value: "\(val)"))
            }
            
            var components = URLComponents()
            components.queryItems = query
            
            let body = components.query!
            if let data = body.data(using: .utf8) {
                let array: [UInt8] = Array([UInt8](data))
                
                let sign_b = try HMAC(key: sekretKey, variant: .sha512).authenticate(array)
                
                let sign = sign_b.toHexString()
                
                if let url = URL(string: "https://poloniex.com/tradingApi") {
                    var request = URLRequest(url: url)
                    request.httpMethod = "POST"
                    request.httpBody = data
                    request.setValue(apiKey , forHTTPHeaderField: "Key")
                    request.setValue(sign, forHTTPHeaderField: "Sign")
                    Alamofire.request(request).responseJSON { response in
                        callback(response)
                    }
                }
            }
        }
        catch{
            
        }
    }
    
    func fetchCurrencies( callback: @escaping (DataResponse<Any>) -> Void ) -> Void {
        Alamofire.request("https://poloniex.com/public?command=returnCurrencies", method: .get).responseJSON { response in
            callback(response);
        };
    }
    
    func fetchBalance( callback: @escaping (DataResponse<Any>) -> Void ) -> Void {
        tradingApiRequest(command: "returnCompleteBalances", parameters: [:]) { response in
            callback(response)
        }
    }
    
    
    func fetchChartData( pair: String, frequency: Int, begin: Date, end: Date, callback: @escaping (DataResponse<Any> ) -> Void ) -> Void
    {
        
        let startTime = String(Int(begin.timeIntervalSince1970))
        let endTime = String(Int(end.timeIntervalSince1970))
        let pars : Parameters = ["command": "returnChartData", 
                                 "currencyPair": pair,
                                 "period": String(frequency),
                                 "start": startTime,
                                 "end" : endTime
                                 ]
        
        Alamofire.request("https://poloniex.com/public", method: .get, parameters: pars, encoding: URLEncoding.default).responseJSON { response in
            callback(response)
        }
    }
    
    func fetchOrders( forPair pair: String, callback handler: @escaping ( [Order] ) -> Void ) {
        tradingApiRequest(command: "returnOpenOrders", parameters: ["currencyPair": pair]) { [unowned self] response in
            guard let array = response.value as? Array<NSDictionary> else { return }
            var orders = [Order]()
            for order_info in array {
                if let order_id = order_info["orderNumber"] as? Int,
                    let typeString = order_info["type"] as? String,
                    let type = OrderType(rawValue: typeString),
                    let amount = order_info["amount"] as? Double,
                    let rate = order_info["rate"] as? Double,
                    let total = order_info["total"] as? Double {
                    
                    let order = Order(orderID: order_id, rate: rate, total: total, amount: amount, type: type, status: .open)
                    orders.append(order)
                }
            }
            
            let now = Date()
            let calendar = Calendar.current
            let start = calendar.date(byAdding: .month, value: -3, to: now)
            let date_string = "\(start?.timeIntervalSince1970 ?? 0)"
            
            self.tradingApiRequest(command: "returnTradeHistory", parameters: ["currencyPair": pair, "start" : date_string]) { response in
                if let array = response.value as? Array<NSDictionary> {
                    var orders = [Order]()
                    let dateFormatter = DateFormatter() 
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    for order_info in array {
                        if let idStr = order_info["orderNumber"] as? String,
                            let order_id = Int(idStr),
                            let typeString = order_info["type"] as? String,
                            let type = OrderType(rawValue: typeString),
                            let amountString = order_info["amount"] as? String,
                            let amount = Double(amountString),
                            let rateString = order_info["rate"] as? String,
                            let rate = Double(rateString),
                            let totalString = order_info["total"] as? String,
                            let total = Double(totalString),
                            let dateString = order_info["date"] as? String {
                            
                            let date = dateFormatter.date(from: dateString)
                            
                            let order = Order(orderID: order_id, rate: rate, total: total, amount: amount, type: type, status: .completed)
                            order.date = date
                            
                            orders.append(order)
                        }
                    }
                    
                    handler(orders)
                }
            }
        }
    }
    
    
    
    func placeOrder( type: OrderType, forPair pair: String, amount: Double, rate: Double, callback: @escaping (DataResponse<Any>) -> Void ) -> Void {
        
        let command = type == .sell ? "sell" : "buy"
        let parameters : Parameters = ["rate" : String(rate),
                                       "amount" : String(amount),
                                       "currencyPair": pair ]
        
        tradingApiRequest(command: command, parameters: parameters) { response in
            callback(response)
        }
    }
}
