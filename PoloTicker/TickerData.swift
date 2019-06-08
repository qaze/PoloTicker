import UIKit
import Alamofire

class TickerData {
    var baseCurrency = String()
    var currency = String()
    var lowerAsk = String()
    var highestBid = String()
    var lower24Hrs = String()
    var higher24hrs = String()
    var baseVolume = String()
    var quoteVolume = String()
    var change24hrs = String()
    var last = String()

    init( tickerDict: NSDictionary, pairNameStr: String ) {
        
        let trimmedPair = pairNameStr.trimmingCharacters(in: .whitespaces)
        let currencies = trimmedPair.components(separatedBy: "_")
        baseCurrency = currencies.first ?? ""
        currency = currencies.last ?? ""
        
        if let value = tickerDict.object(forKey: "lowestAsk") as? String, let dValue = Double(value) {
            lowerAsk = String(format: "%.5f", dValue)
        }
        
        if let value = tickerDict.object(forKey: "highestBid") as? String, let dValue = Double(value) {
            highestBid = String(format: "%.5f", dValue)
        }
        
        if let value = tickerDict.object(forKey: "high24hr") as? String, let dValue = Double(value) {
            higher24hrs = String(format: "%.5f", dValue)
        }
        
        if let value = tickerDict.object(forKey: "low24hr") as? String, let dValue = Double(value) {
            lower24Hrs = String(format: "%.5f", dValue)
        }
        
        if let value = tickerDict.object(forKey: "baseVolume") as? String, let dValue = Double(value) {
            baseVolume = String(format: "%.5f", dValue)
        }
        
        if let value = tickerDict.object(forKey: "quoteVolume") as? String, let dValue = Double(value) {
            quoteVolume = String(format: "%.5f", dValue)
        }
        
        if let value = tickerDict.object(forKey: "last") as? String, let dValue = Double(value) {
            last = String(format: "%.5f", dValue)
        }
        
        if let percentString = tickerDict.object(forKey: "percentChange") as? String, let percent = Double(percentString) {
            change24hrs = String( format: "%.2f", percent * 100.0)
            if( percent >= 0.0 ) {
                change24hrs.insert("+", at: change24hrs.startIndex)
            }
        }
    }
}
