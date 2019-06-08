import UIKit

class Coin {
    
    var isWatching = false
    
    var tickers : Dictionary = [String: TickerData]()
    let name : String
    let fullName : String
    
    var quantity: String
    var btcEstimated: String
    
    init( coinName : String, coinFullName : String, value: String, btc: String ) {
        name = coinName
        quantity = value
        btcEstimated = btc
        fullName = coinFullName
    }
    
    func setTickerInfo( info : TickerData )
    {
        tickers[info.baseCurrency] = info 
    }
    
    func hasValue() -> Bool 
    {
        return (Double(quantity) ?? 0.0) > 0.1;
    }
    
    func infoFor( baseCoin coin: String ) -> TickerData?
    {
        return tickers.first { (key, value) -> Bool in
            return value.baseCurrency.compare(coin) == .orderedSame
        }?.value
    }
}
