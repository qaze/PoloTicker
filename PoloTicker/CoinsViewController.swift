import UIKit
import Alamofire

class CoinsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tickerTable: UITableView!
    @IBOutlet weak var allBtcValue: UILabel!
    @IBOutlet weak var usdtValue: UILabel!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var watchFilterButton: UIBarButtonItem!
    
    let coinsManager : CoinsManager = CoinsManager()
    
    var isWatchedFiltered = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reloadData()
    }
    
    func reloadData()
    {
        DispatchQueue.main.async {
            self.activity.startAnimating()
            self.tickerTable.isHidden = true
            self.allBtcValue.isHidden = true
            self.usdtValue.isHidden = true
        }
        
        coinsManager.refreshCoins { [weak self] status, manager in
            if( status == .Success )
            {
                DispatchQueue.main.async { [weak self, manager] in
                    self?.allBtcValue.text = String(format: "%.5f B", manager.btcValue)
                    self?.usdtValue.text = String(format: "%.5f $", manager.btcValue * manager.usdtValue)
                    
                    if( self?.isWatchedFiltered == true )
                    {
                        manager.filterWatched()
                    }
                    
                    self?.tickerTable.reloadData()
                    self?.activity.stopAnimating()
                    self?.tickerTable.isHidden = false
                    self?.allBtcValue.isHidden = false
                    self?.usdtValue.isHidden = false
                }
            }
        }
    }

    @IBAction func update(_ sender: Any) {
        self.reloadData()
    }
    
    private func favoriteAtPath( path: IndexPath ){
        let coin = coinsManager.coins[path.row]
        coin.isWatching = !coin.isWatching
        
        self.tickerTable.reloadRows(at: [path], with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
       
        let coin = coinsManager.coins[indexPath.row]
        
        if coin.isWatching {
            let favoriteAction = UITableViewRowAction(style: .normal, title: "Unwatch") { (action, path) in
                self.favoriteAtPath(path: path)
            }
            
            favoriteAction.backgroundColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
            
            return [favoriteAction]
        }
        else {
            let favoriteAction = UITableViewRowAction(style: .normal, title: "Watch") { (action, path) in
                self.favoriteAtPath(path: path)
            }
            
            favoriteAction.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
            
            return [favoriteAction]
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func filterWatched(_ sender: Any) {
        isWatchedFiltered = !isWatchedFiltered
        
        if isWatchedFiltered {
            watchFilterButton.image = UIImage(named: "eye_active")
        } else {
            watchFilterButton.image = UIImage(named: "eye")
        }
        
        reloadData()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coinsManager.coins.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "coinCell") as? CoinCell {
            cell.configure(coin: coinsManager.coins[indexPath.row]);
            return cell
        }
        
        fatalError("Table is wrong configured")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier?.compare("coinSegue") == .orderedSame {
            if let coinVC = segue.destination as? CoinViewController,
                let senderCell = sender as? CoinCell,
                let coin = senderCell.coin {
                coinVC.configure(coin: coin, manager: coinsManager) 
            }
        }
    }
}

