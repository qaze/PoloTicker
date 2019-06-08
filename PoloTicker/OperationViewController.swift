import UIKit

class OperationViewController: UIViewController, UITextFieldDelegate {

    var ticker : TickerData?
    var operationType : OrderType = .sell
    weak var manager : CoinsManager?
    
    @IBOutlet weak var operation: UILabel!
    @IBOutlet weak var currency: UILabel!
    @IBOutlet weak var price: UITextField!
    @IBOutlet weak var amount: UITextField!
    @IBOutlet weak var total: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let t = ticker {
            guard let priceText = price?.text,
                let amountText = amount?.text,
                let priceD = Double(priceText),
                let amountD = Double(amountText)
                else { return }
            
            if operationType == .sell {
                operation.text = "Sell"
                currency.text = String(format: "%@ to %@", t.currency, t.baseCurrency)
                price.text = String( t.highestBid )
            }
            else {
                operation.text = "Buy"
                currency.text = String(format: "%@ for %@", t.currency, t.baseCurrency)
                price.text = String( t.lowerAsk )
            }
            
            amount.text = "1"
            self.total.text = String(priceD*amountD)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let priceText = price?.text,
            let totalText = total?.text,
            let amountText = amount?.text else { return }
        
        if (textField == price || textField == amount), 
            let price = Double(priceText), 
            let amount = Double(amountText) 
        {
            self.total.text = String(price * amount)
        }
            
        else if textField == total,
            let price = Double(priceText), 
            let total = Double(totalText)
        {
            self.amount.text = String(price * total)
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func proceed(_ sender: Any) {
        guard let ticker = ticker else { return }
        let pairName = String(format: "%@_%@", 
                              (ticker.baseCurrency), 
                              (ticker.currency))
        
        if let am = amount.text, let pr = price.text, let amDouble = Double(am), let prDouble = Double(pr) {
            manager?.placeOrder(type: operationType, forPair: pairName, amount: amDouble, rate: prDouble ) { string in
                let controller = UIAlertController(title: nil, message: string, preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: { action in
                    self.dismiss(animated: true, completion: nil)
                })
                controller.addAction(action)
                self.show(controller, sender: self)
            }
        } 
    }
    
}
