//
//  TableViewCell.swift
//  todo_tableView
//
//  Created by Artem Grebinik on 01.03.2018.
//  Copyright © 2018 Artem Hrebinik. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
   
    @IBOutlet weak var textView: UITextView!
    
    var toDoItem: Task? {
        didSet{
            guard let dealStr = toDoItem?.deal else { return }
            
            let font = UIFont(name: "ChalkboardSE-Light", size: 24)!
            let attrStr = NSAttributedString(string: dealStr, attributes: [NSAttributedStringKey.font : font,
                                                                           NSAttributedStringKey.foregroundColor : UIColor.darkGray])            
            self.textView.attributedText = attrStr
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
