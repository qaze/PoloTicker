import UIKit
import Charts

enum CoinsStatus {
    case Success
    case Failed
}

class CoinsManager {
    var coins = [Coin]();
    var btcValue = 0.0
    var usdtValue = 0.0
    private let connection = PoloConnection()
    
    private func setTicker( ticker : TickerData )
    {
        let i = coins.firstIndex { coin -> Bool in
            return coin.name.compare(ticker.currency) == .orderedSame
        }
        
        if let index = i {
            coins[index].setTickerInfo(info: ticker)
        }
    }
    
    private func refreshTickers( completion : @escaping ( _ status: CoinsStatus ) -> Void ){
        connection.fetchTickers { response in
            let dict: NSDictionary = response.result.value as! NSDictionary;
            dict.enumerateKeysAndObjects({ (key, value, stop) in
                guard let value = value as? NSDictionary, let key = key as? String else { return }
                let ticker = TickerData(tickerDict: value, pairNameStr: key)
                self.setTicker(ticker: ticker)
                
                if ticker.baseCurrency.compare("USDT") == .orderedSame && ticker.currency.compare("BTC") == .orderedSame {
                    self.usdtValue = Double( ticker.last ) ?? 0.0
                }
            })
            completion(.Success)
        }
    }
    
    func filterWatched() -> Void {
        self.coins = self.coins.filter { coin -> Bool in
            return coin.isWatching
        }
    }
    
    
    func refreshBalances(completion : @escaping ( _ status: CoinsStatus ) -> Void) {
        connection.fetchBalance { response in
            if let balances: NSDictionary = response.result.value as? NSDictionary {
                for (key, val) in balances {
                    guard let val_dict = val as? NSDictionary else { continue }
                    guard let name = key as? String, name != "USDC", name != "USDT" else { continue }
                    guard let btc_val_str = val_dict["btcValue"] as? String else { continue }
                    guard let btc_val = Double(btc_val_str), btc_val > 0.0 else { continue }
                    guard let available_str = val_dict["available"] as? String else { continue }
                    guard let available = Double(available_str), available > 0.0 else { continue }
                    
                    self.btcValue += btc_val
                    
                    let index = self.coins.firstIndex(where: { coin -> Bool in
                        return coin.name.compare(name) == .orderedSame
                    })
                    
                    if let i = index 
                    {   
                        let quantity = String(format: "%.5f", available)
                        let btcEstimated = String(format: "%.5f B", btc_val)
                        let coin = self.coins[i]
                        coin.btcEstimated = btcEstimated
                        coin.quantity = quantity
                    }
                }
            }
            
            self.refreshTickers(completion: { (status) in
                
                self.coins = self.coins.sorted(by: { (coin1, coin2) -> Bool in
                    if coin1.name == "BTC" {
                        return true
                    }
                    else if coin2.name == "BTC" {
                        return false
                    }
                    
                    if coin1.isWatching {
                        return true
                    }
                    else if coin2.isWatching {
                        return false
                    }
                    
                    if coin1.hasValue() {
                        return true
                    }
                    else if coin2.hasValue() {
                        return false
                    }
                    
                    let btc1_o = coin1.infoFor(baseCoin: "BTC")
                    let btc2_o = coin2.infoFor(baseCoin: "BTC")
                    
                    guard let btc1 = btc1_o else {
                        return false
                    }
                    
                    guard let btc2 = btc2_o else {
                        return true
                    }
                    
                    guard let value1 = Double(btc1.baseVolume) else { return false }
                    guard let value2 = Double(btc2.baseVolume) else { return true }
                    
                    return value1 > value2
                })
                completion(status)
            })
        }
    }
    
    func fetchChartData( pair: String, frequency: Int, begin: Date, end: Date, callback: @escaping ([CandleChartDataEntry]) -> Void ) {
        connection.fetchChartData(pair: pair, frequency: frequency, begin: begin, end: end) { [callback] (response) in
            if let array = response.value as? NSArray {
                var counter = 0
                let vals = array.compactMap { (i) -> CandleChartDataEntry? in
                    if let dict = i as? NSDictionary,
                        let high = dict["high"] as? Double,
                        let low = dict["low"] as? Double,
                        let open = dict["open"] as? Double,
                        let close = dict["close"] as? Double,
                        let date_d = dict["date"] as? Double {
                        
                        let date = Date(timeIntervalSince1970: date_d)
                        
                        let result = CandleChartDataEntry(x: Double(counter), shadowH: high, shadowL: low, open: open, close: close, data: date as AnyObject)
                        
                        counter += 1
                        return result
                    }
                    
                    return nil
                }
                
                callback(vals)
            }
            else {
                callback([])
            }
        }
    }
    
    func placeOrder( type: OrderType, forPair pair: String, amount: Double, rate: Double, callback: @escaping (String) -> Void ) {
        connection.placeOrder(type: type, forPair: pair, amount: amount, rate: rate) { [callback] (response) in
            guard let value = response.value else { callback("Unkown Error"); return }
            if let info = try? JSONSerialization.data(withJSONObject: value, options: .prettyPrinted) {
                let string = String(data: info, encoding: .utf8)
                callback(string ?? "Unkown Error")
            }
            else {
                callback("Unkown Error")
            }
        }
    }
    
    func fetchOrders( forPair pair: String, callback handler: @escaping ( [Order] ) -> Void ) {
        connection.fetchOrders(forPair: pair, callback: handler)
    }
    
    func refreshCoins( completion : @escaping ( _ status: CoinsStatus, _ manager: CoinsManager ) -> Void ) -> Void
    {
        self.btcValue = 0.0
        self.usdtValue = 0.0
        
        connection.fetchCurrencies { (currencies_data) in
            if let dict: NSDictionary = currencies_data.result.value as? NSDictionary {
                dict.enumerateKeysAndObjects({ (key, value, stop) in
                    guard let value_dict = value as? NSDictionary else { return }
                    guard let name = key as? String, name != "USDT", name != "USDC" else { return }
                    guard let fullName = value_dict["name"] as? String else { return }
                    
                    
                    if let disabled = value_dict["disabled"] as? Int, disabled == 1 {
                        return
                    }
                    
                    if let delisted = value_dict["delisted"] as? Int, delisted == 1 {
                        return
                    }
                    
                    
                    
                    let index = self.coins.firstIndex(where: { coin -> Bool in
                        return coin.name.compare(name) == .orderedSame
                    })
                    
                    if index == nil {
                        let coin = Coin(coinName: name, coinFullName: fullName, value: "0", btc: "0")
                        self.coins.append(coin)
                    }
                })
                
                self.refreshBalances(completion: { [weak self] (status) in
                    guard let self = self else { return }
                    completion(status, self)
                })
            }
        }
    }
}
