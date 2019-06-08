import UIKit

class OrderTableViewCell: UITableViewCell {
    @IBOutlet weak var rate: UILabel!
    @IBOutlet weak var amount: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var status: UIImageView!
    @IBOutlet weak var total: UILabel!
    
    override func prepareForReuse() {
        self.rate.text = "Rate"
        self.amount.text = "Amount"
        self.total.text = "Total"
        self.type.text = "Type"
        self.status.image = #imageLiteral(resourceName: "completed")
    } 
    
    func configure( order: Order ) {
        self.rate.text = String( order.rate )
        self.amount.text = String( order.amount )
        self.total.text = String( order.total )
        self.type.text = order.type == .sell ? "Sell" : "Buy"
        self.status.image = order.status == .completed ? #imageLiteral(resourceName: "completed") : #imageLiteral(resourceName: "in_progress")
    }
    
}
