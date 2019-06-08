import UIKit
import Charts

open class CandleMarker: MarkerView {
    
    @IBOutlet weak var open: UILabel!
    @IBOutlet weak var close: UILabel!
    @IBOutlet weak var high: UILabel!
    @IBOutlet weak var low: UILabel!
    @IBOutlet weak var date: UILabel!
    
    @IBOutlet weak var internalView: UIView!
    
    
    override open func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        
        self.layer.cornerRadius = 5.0
        internalView.layer.cornerRadius = 5.0
        self.clipsToBounds = true
        internalView.clipsToBounds = true
        
        if let data = entry as? CandleChartDataEntry {
            open.text = String(format: "%g", data.open)
            close.text = String(format: "%g", data.close)
            high.text = String(format: "%g", data.high)
            low.text = String(format: "%g", data.low)
            
            
            if let xDate = data.data as? Date { 
                let formatter : DateFormatter = DateFormatter()
                formatter.dateFormat = "dd/MM HH:mm:ss"
                date.text = formatter.string(from: xDate)
            }
        }
    }
}
