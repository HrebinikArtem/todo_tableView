//
//  ViewController.swift
//  todo_tableView
//
//  Created by Artem Grebinik on 01.03.2018.
//  Copyright © 2018 Artem Hrebinik. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
// MARK: - IBOutlets
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!

    
    
    
// MARK: - Property
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private lazy var gradient: CAGradientLayer = {
       let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 0, y: 1)
        gradient.colors = [#colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1).cgColor, #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1).cgColor]
        
        return gradient
    }()
    
    
    private lazy var errorAlert: UIAlertController = {
        let alert = UIAlertController(title: "Error", message: "Введите текст", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel))
        
        return alert
    }()
    
    

    
// MARK: - Deinit

    deinit {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
    }
    
    
    
// MARK: - ViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layer.insertSublayer(gradient, at: 0)
        textView.becomeFirstResponder()
        
        setupNotification()
    }
    

    
    
// MARK: - Methods
    
    private func setupNotification() {
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(with:)),
                                               name: .UIKeyboardWillShow,
                                               object: nil)
    }

    @objc func keyboardWillShow(with notification: Notification) {
    
        let key = "UIKeyboardFrameEndUserInfoKey"
        
        guard let keyboardFrame = notification.userInfo?[key] as? NSValue else { return }
        
        let keyboardHeight = keyboardFrame.cgRectValue.height + 16
        
        bottomConstraint.constant = keyboardHeight
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    
    
    
// MARK: - Actions

    @IBAction func cancelButtonAction(_ sender: UIButton) {
        
        textView.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonAction(_ sender: UIButton) {
    
        guard let text = self.textView.text else { return }
        
        if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty{
            
        NotificationCenter.default.post(name: NSNotification.Name.init("NotificationFromDetailVC"),
                                            object: nil,
                                            userInfo: ["text": text])
            
        dismiss(animated: true, completion: nil)
            
        } else {
            present(errorAlert, animated: true)
        }
    }
}




// MARK: - Extension

extension ViewController: UITextViewDelegate {
   
    func textViewDidChangeSelection(_ textView: UITextView) {
        
        if doneButton.isHidden {

            guard let temp = textView.text.last else { return }
            
            textView.text = String(temp)
            textView.textColor = .white

            doneButton.isHidden = false
            doneButton.isEnabled = false
            doneButton.backgroundColor = .red

            layoutIn()

        } else {

            if textView.text.count < 1 {
                doneButton.isHidden = true
                layoutIn()
                
            } else if textView.text.count < 5 {
                
                doneButton.isEnabled = false
                doneButton.backgroundColor = .red
                
            } else {
                doneButton.isEnabled = true
                doneButton.backgroundColor = .green
            }
        }
    }
    
    func layoutIn() {
        UIView.animate(withDuration: 0.3, animations: {
            self.view.layoutIfNeeded()
        })
    }
}



