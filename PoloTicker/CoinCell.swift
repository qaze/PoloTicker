import UIKit

class CoinCell: UITableViewCell {
    
    @IBOutlet weak var coinName: UILabel!
    @IBOutlet weak var quantity: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var fullName: UILabel!
    
    // BTC Block
    @IBOutlet weak var btcBlock: UIView!
    @IBOutlet weak var btcValue: UILabel!
    @IBOutlet weak var btcChange24hrs: UILabel!
    
    // ETH Block
    @IBOutlet weak var ethBlock: UIView!
    @IBOutlet weak var ethValue: UILabel!
    @IBOutlet weak var ethChange24hrs: UILabel!
    
    // XMR Block
    @IBOutlet weak var xmrBlock: UIView!
    @IBOutlet weak var xmrValue: UILabel!
    @IBOutlet weak var xmrChange24hrs: UILabel!
    
    // USDT Block
    @IBOutlet weak var usdtBlock: UIView!
    @IBOutlet weak var usdtValue: UILabel!
    @IBOutlet weak var usdtChange24hrs: UILabel!
    
    @IBOutlet weak var watchIndicator: UIView!
    
    var coin : Coin?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        coinName.text = "----"
        quantity.text = "----"
        icon.image = nil
        
        // BTC Block
        btcBlock.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        btcValue.text = "N/A"
        btcChange24hrs.text = "----"
        
        // ETH Block
        ethBlock.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        ethValue.text = "N/A"
        ethChange24hrs.text = "----"
        
        // XMR Block
        xmrBlock.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        xmrValue.text = "N/A"
        xmrChange24hrs.text = "----"
        
        // USDT Block
        usdtBlock.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        usdtValue.text = "N/A"
        usdtChange24hrs.text = "----"
        
        self.contentView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
    
    func configure( coin: Coin) -> Void {
        self.coin = coin
        
        DispatchQueue.main.async {
            self.coinName.text = coin.name;
            self.icon.image = UIImage(named: coin.name.lowercased() )
            
            
            self.quantity.text = coin.quantity
            
            if coin.hasValue() {
                self.contentView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 0.8978342282, alpha: 1)
            }
            
            // btc
            self.btcBlock.layer.borderWidth = 1.0
            self.btcBlock.layer.borderColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
            self.btcBlock.clipsToBounds = true
            self.btcBlock.layer.cornerRadius = self.btcBlock.frame.height / 2.0
            if let ticker = coin.infoFor(baseCoin: "BTC") 
            {
                self.btcChange24hrs.text = ticker.change24hrs
                self.btcValue.text = ticker.last

                
                if( ticker.change24hrs.firstIndex(of: "-") != nil )
                {
                    self.btcBlock.backgroundColor = #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1)
                }
                else
                {
                    self.btcBlock.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
                }
            }
            
            self.ethBlock.layer.borderWidth = 1.0
            self.ethBlock.layer.borderColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
            self.ethBlock.clipsToBounds = true
            self.ethBlock.layer.cornerRadius = self.ethBlock.frame.height / 2.0
            
            // eth
            if let ticker = coin.infoFor(baseCoin: "ETH") 
            {
                self.ethChange24hrs.text = ticker.change24hrs
                self.ethValue.text = ticker.last
                
                if( ticker.change24hrs.firstIndex(of: "-") != nil )
                {
                    self.ethBlock.backgroundColor = #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1)
                }
                else
                {
                    self.ethBlock.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
                }
            }
            
            //xmr
            self.xmrBlock.layer.borderWidth = 1.0
            self.xmrBlock.layer.borderColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
            self.xmrBlock.clipsToBounds = true
            self.xmrBlock.layer.cornerRadius = self.xmrBlock.frame.height / 2.0
            if let ticker = coin.infoFor(baseCoin: "XMR") 
            {
                self.xmrChange24hrs.text = ticker.change24hrs
                self.xmrValue.text = ticker.last

                
                if( ticker.change24hrs.firstIndex(of: "-") != nil )
                {
                    self.xmrBlock.backgroundColor = #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1)
                }
                else
                {
                    self.xmrBlock.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
                }
            }
            
            self.usdtBlock.layer.borderWidth = 1.0
            self.usdtBlock.layer.borderColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
            self.usdtBlock.clipsToBounds = true
            self.usdtBlock.layer.cornerRadius = self.usdtBlock.frame.height / 2.0
            // usdt
            if let ticker = coin.infoFor(baseCoin: "USDT") 
            {
                self.usdtChange24hrs.text = ticker.change24hrs
                self.usdtValue.text = ticker.last

                
                if( ticker.change24hrs.firstIndex(of: "-") != nil )
                {
                    self.usdtBlock.backgroundColor = #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1)
                }
                else
                {
                    self.usdtBlock.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
                }
            }
            
            if coin.isWatching {
                self.watchIndicator.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
            }
            else {
                self.watchIndicator.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            }
            
            self.fullName.text = coin.fullName
        }
        
    }
    
}
