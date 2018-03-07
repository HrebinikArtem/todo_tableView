//
//  TableViewController.swift
//  todo_tableView
//
//  Created by Artem Grebinik on 01.03.2018.
//  Copyright © 2018 Artem Hrebinik. All rights reserved.
//

import UIKit
import CoreData

class TableViewController: UITableViewController {
    
// MARK: - Property
    
    var context: NSManagedObjectContext!
    
    private var itemsList:[Task?]? = [] {
        didSet{
            self.tableView.reloadData()
        }
    }
    
    
    
// MARK: - deinit

    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.init("NotificationFromDetailVC"), object: nil)
    }
    
    
    
// MARK: - ViewController
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
     
        loadingTasksFromCoreData()
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNotification()
        setGradientForNavigationBar()
    }

    
// MARK: - Methodts
    
    private func setupNotification() {
       
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(gotNotification),
                                               name: NSNotification.Name.init("NotificationFromDetailVC"),
                                               object: nil)
    }
    
    @objc private func gotNotification(notification: Notification) {
        
        guard let userInfo =  notification.userInfo else { return }
        guard let text = userInfo["text"] as? String else { return }
        
        saveTask(with: text)
    }
    
    private func setupContextualAction(with style: UIContextualAction.Style, title: String,indexPath: IndexPath, colors: [CGColor]) -> UIContextualAction {
        
        var action = UIContextualAction()
        
        switch style {
       
        case .destructive:
           
            action = UIContextualAction(style: style, title: title) { (action, view, completion) in
                self.deleteTaskAt(selected: indexPath)
                completion(true)
            }
            
        case .normal:
            
            action = UIContextualAction(style: style, title: title) { (action, view, completion) in
                completion(true)
            }
        }
        
        action.backgroundColor = setGradientForContextualAction(at: indexPath, with: colors)
        return action
    }
    
    private func setGradientForNavigationBar() {
        if let navFrame = self.navigationController?.navigationBar.frame {
            
            let newframe = CGRect(origin: .zero, size: CGSize(width: navFrame.width, height: (navFrame.height + UIApplication.shared.statusBarFrame.height + 150)))
            print(newframe)
            
            let colors = [#colorLiteral(red: 0.1450980392, green: 0.5882352941, blue: 0.9843137255, alpha: 1).cgColor, #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1).cgColor, #colorLiteral(red: 0.1450980392, green: 0.5882352941, blue: 0.9843137255, alpha: 1).cgColor] //2596FB - синий в hex
            
            let image = gradientWithFrameToImage(frame: newframe, colors: colors, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: 1))!
            
            self.navigationController?.navigationBar.barTintColor = UIColor(patternImage: image)
        }
    }
    
    private func setGradientForContextualAction(at indexPath: IndexPath, with colors: [CGColor]) -> UIColor {
        
        let cellFrame = (tableView.cellForRow(at: indexPath)!).frame
        let newframe = CGRect(origin: .zero, size: CGSize(width: cellFrame.width, height: cellFrame.height))
        let image = gradientWithFrameToImage(frame: newframe, colors: colors, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 1, y: 0))!
        
        return UIColor(patternImage: image)
    }
    
    func gradientWithFrameToImage(frame: CGRect, colors: [CGColor], start:CGPoint, end:CGPoint) -> UIImage? {
        let gradient: CAGradientLayer  = CAGradientLayer(layer: self.view.layer)
        gradient.frame = frame
        gradient.startPoint = start
        gradient.endPoint = end
        gradient.colors = colors
        UIGraphicsBeginImageContext(frame.size)
        gradient.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }

    
    
    
// MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        if let count = itemsList?.count {
            return count
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        
        cell.toDoItem = itemsList?[indexPath.item]

        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    
        if let str = itemsList?[indexPath.item]?.deal{
            
            let font = UIFont(name: "ChalkboardSE-Light", size: 24)!
            let attrStr = NSAttributedString(string: str, attributes: [NSAttributedStringKey.font : font,
                                                                       NSAttributedStringKey.foregroundColor : UIColor.red])
            
            
            let size = attrStr.boundingRect(with: CGSize(width: view.frame.width , height: 1000),
                                            options: NSStringDrawingOptions.usesFontLeading.union(NSStringDrawingOptions.usesLineFragmentOrigin),
                                            context: nil).size
            return size.height + 20
        }        
        return 80
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let colorsForCheckAction = [#colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1).cgColor,#colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1).cgColor]

        let checkAction = setupContextualAction(with: .destructive, title: "Check", indexPath: indexPath, colors: colorsForCheckAction)
        checkAction.image = UIImage(named: "check")
        checkAction.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)

        return UISwipeActionsConfiguration(actions: [checkAction])
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {

        let colorsForDeletAction = [#colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1).cgColor,#colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1).cgColor]
        let colorsForNotifiAction = [#colorLiteral(red: 0.1450980392, green: 0.5882352941, blue: 0.9843137255, alpha: 1).cgColor,#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).cgColor]

        let deletAction = setupContextualAction(with: .destructive, title: "Delete", indexPath: indexPath, colors: colorsForDeletAction)
        deletAction.image = UIImage(named: "trash")
        
       
        let notifiAction = setupContextualAction(with: .normal, title: "Notifi", indexPath: indexPath, colors: colorsForNotifiAction)
        notifiAction.image = UIImage(named: "clock")
        
        return UISwipeActionsConfiguration(actions: [deletAction,notifiAction])
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        print("canMoveRowAt")

        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        print("moveRowAt")
    }
    
    
    
// MARK: - CoreData
    
    private func loadingTasksFromCoreData() {
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()

        do {
            let tempArray = try context.fetch(fetchRequest)
            self.itemsList = Array(tempArray.reversed())

        }catch {
            print(error.localizedDescription)
        }
    }
    
    private func saveTask(with toDoString: String) {
        
        let entity = NSEntityDescription.entity(forEntityName: "Task", in: context)
        let task = NSManagedObject(entity: entity!, insertInto: context) as! Task
        
        task.deal = toDoString
        
        do {
            try context.save()
            self.itemsList?.insert(task, at: 0)
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func deleteTaskAt(selected indexPath: IndexPath) {
        
        if let taskObject = itemsList?[indexPath.item] {
            
            context.delete(taskObject)
            
            do {
                try context.save()
                itemsList?.remove(at: indexPath.item)
                
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}


