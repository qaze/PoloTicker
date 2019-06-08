import UIKit
import Charts
import ActionSheetPicker_3_0

class CoinViewController: UIViewController, 
    ChartViewDelegate, 
    IAxisValueFormatter, 
    IValueFormatter,
    UITableViewDataSource{

    @IBOutlet weak var chart: CandleStickChartView!
    @IBOutlet weak var coinButton: UIBarButtonItem!
    
    var dataSet: CandleChartDataSet?
    
    var orders: [Order] = []
    var tickers: [String] = []
    var choosedBaseName: String = ""
    weak var manager: CoinsManager?
    
    private let frequencies = [
         300, 900, 1800, 7200, 14400, 86400
    ]
    
    private let begins = [
        360, 1440, 2880, 5760, 10080, 20160, 40320, 1
    ]
    
    var choosedBeginIndex: Int = 1
    var choosedPeriodIndex: Int = 3
    private let beginNames = [  "6h", "24h",  "2d",  "4d",  "1w",  "2w",  "1m",  "1Year" ]
    private let periodNames = [  "5-min", "15-min", "30-min", "2-hr", "4-hr", "1-day" ]
    
    @IBOutlet weak var ordersTable: UITableView!
    
    var coin : Coin?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chart.delegate = self
        chart.chartDescription?.enabled = false
        
        chart.dragEnabled = true
        chart.setScaleEnabled(true)
        chart.pinchZoomEnabled = true
        chart.legend.enabled = false
        
        if let font = UIFont(name: "HelveticaNeue-Light", size: 10) {
            chart.leftAxis.labelFont = font 
        }
        chart.rightAxis.enabled = false
        
        chart.xAxis.labelRotationAngle = 45
        chart.xAxis.valueFormatter = self
        chart.xAxis.labelPosition = .bottom
        
        if let font = UIFont(name: "HelveticaNeue", size: 10) {
            chart.xAxis.labelFont = font
        }
        
        chart.drawMarkers = true
        chart.drawGridBackgroundEnabled = false
        
        chart.highlightPerTapEnabled = true
        chart.highlightPerDragEnabled = true
        
        chart.leftAxis.drawGridLinesEnabled = false
        chart.xAxis.drawGridLinesEnabled = false
        
        let marker = CandleMarker.viewFromXib()
        marker?.chartView = chart
        chart.marker = marker
        chart.drawMarkers = true
        
        if let c = coin {
            for (key, _) in c.tickers {
                self.tickers.append(key)
            }
        }
        
        choosedBaseName = tickers[0]
        coinButton.title = choosedBaseName
        
        self.refresh(self)
    }
    
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        
        if value > 1000 {
            return String(format: "%.0f", value)
        }
        else if value > 0.1 {
            return String(format: "%.2f", value)
        }
        else if value > 0.01{
            return String(format: "%.3f", value)
        }
        else {
            return String(format: "%.5f", value)
        }
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        
    }
    
    @IBAction func chooseCoin(_ sender: Any) {
        let alert = UIAlertController(title: "Choose base coin", message: nil, preferredStyle: .actionSheet)
        for i in tickers {
            let action = UIAlertAction(title: i, style: .default) { action in
                self.choosedBaseName = i
                self.refresh(self)
            }
            alert.addAction(action)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            
        }
        
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func moreClicked(_ sender: Any) {
        ActionSheetMultipleStringPicker.show(withTitle: "Choose begin and period", 
                                     rows: [ periodNames, beginNames ], 
                                     initialSelection: [choosedPeriodIndex, choosedBeginIndex], 
                                     doneBlock: { (picker, indexes, values) in
                                        self.choosedPeriodIndex = indexes?[0] as? Int ?? 0
                                        self.choosedBeginIndex = indexes?[1] as? Int ?? 0
                                        self.refresh(self)
        }, cancel: { (picker) in
            
        }, origin: self.coinButton)
        
    }
    

    @IBAction func refresh(_ sender: Any) {
        self.chart.data = nil
        if let c = coin {
            
            let now = Date()
            
            let calendar = Calendar.current
            var compnent : Calendar.Component = .minute
            
            if choosedBeginIndex == begins.count - 1 {
                compnent = .year
            }
            
            let begin = calendar.date(byAdding: compnent, value: -begins[choosedBeginIndex], to: Date()) 
            
            let pairName = String(format: "%@_%@", 
                                  choosedBaseName,
                                  c.name )
            
            manager?.fetchChartData(pair: pairName, 
                                          frequency: frequencies[choosedPeriodIndex], 
                                          begin: begin!, 
                                          end: now) 
            { data in
                let set = CandleChartDataSet(entries: data, label: pairName)
                set.highlightEnabled = true
                set.setDrawHighlightIndicators(true)
                set.highlightColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1)
                
                set.axisDependency = .left
                set.setColor(UIColor(white: 80/255, alpha: 1))
                set.decreasingColor = #colorLiteral(red: 0.9372549057, green: 0.3490196168, blue: 0.1921568662, alpha: 1)
                set.decreasingFilled = true
                set.increasingColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
                set.increasingFilled = true
                set.neutralColor = .blue
                set.drawValuesEnabled = true
                set.valueFormatter = self
                set.drawVerticalHighlightIndicatorEnabled = true
                set.drawHorizontalHighlightIndicatorEnabled = true
                self.dataSet = set
                
                let data = CandleChartData(dataSet: set)
                self.chart.data = data
                let base = self.choosedBaseName
                self.navigationItem.title = String(format: "%@: %@", 
                                                   c.name,
                                                   (self.coin?.infoFor(baseCoin: base)?.last)! )
            }
            
            refreshOrders()
        }
        
    }
    
    func refreshOrders()
    {
        if let c = coin {
            let pairName = String(format: "%@_%@", 
                                  choosedBaseName, 
                                  c.name )
            
            manager?.fetchOrders(forPair: pairName) 
            { fetchedOrders in
                self.orders = fetchedOrders
                DispatchQueue.main.async {
                    self.ordersTable.reloadData()
                }
            }
        }
    }
    
    @IBAction func buy(_ sender: Any) {
        
    }
    
    @IBAction func sell(_ sender: Any) {
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "orderCell") as! OrderTableViewCell
        
        if indexPath.row > 0 {
            cell.configure(order: orders[indexPath.row-1])
        }
        
        return cell
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        var result = ""
        if let data = self.dataSet {
            let index = Int(value)
            if index < data.entries.count {
                let date = data.entries[index].data as! Date 
                let formatter : DateFormatter = DateFormatter()
                
                if choosedBeginIndex < 2 {
                    formatter.dateFormat = "HH:mm"
                }
                else if choosedBeginIndex < begins.count - 1 {
                    formatter.dateFormat = "d/M"
                }
                else {
                    formatter.dateFormat = "MMMM"
                }
                
                result = formatter.string(from: date)
            }
        }
        
        return result
    }
    
    func configure( coin c : Coin, manager : CoinsManager ) {
        coin = c
        self.manager = manager
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "buySegue", let vc = segue.destination as? OperationViewController {
            vc.operationType = .buy
            let base = choosedBaseName
            vc.ticker = self.coin?.infoFor(baseCoin: base)
            vc.manager = manager
        }
        else if segue.identifier == "sellSegue", let vc = segue.destination as? OperationViewController {
            vc.operationType = .sell
            let base = choosedBaseName
            vc.ticker = self.coin?.infoFor(baseCoin: base)
            vc.manager = manager
        }
    }
}
