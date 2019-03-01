//
//  ViewController.swift
//  WordScrambler
//
//  Created by Stefan Milenkovic on 2/27/19.
//  Copyright © 2019 Stefan Milenkovic. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    
    var allWords = [String]()
    var usedWords = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(startGame))
        
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWors = try? String(contentsOf: startWordsURL) {
                allWords = startWors.components(separatedBy: "\n")
            }
        }
        
        if allWords.isEmpty {
            allWords = ["silkworm"]
        }
        
        startGame()
        
    }
    
    

    
    
    @objc func promptForAnswer() {
        
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        
        ac.addTextField()
        
        let submitAciton = UIAlertAction(title: "Submit", style: .default) {
            [weak self, weak ac] _ in
            guard let answer = ac?.textFields?[0].text else {return}
            self?.submit(answer)
            
        }
        
        ac.addAction(submitAciton)
        present(ac, animated: true, completion: nil)
        
        
        
    }
    
    func submit(_ answer: String) {
        
        let lowerAnswer = answer.lowercased()

        if isNotShortOrSameAsStartWord(word: lowerAnswer) {
            if isPossible(word: lowerAnswer) {
                if isOriginal(word: lowerAnswer) {
                    if isReal(word: lowerAnswer) {
                        
                        usedWords.insert(lowerAnswer, at: 0)
                        
                        let indexPath = IndexPath(row: 0, section: 0)
                        tableView.insertRows(at: [indexPath], with: .automatic)
                        
                        return
                        
                    }else {
                        showErrorMessage(title: "Word not recognised", message: "You can't just make them up, you know!")
                    }
                }else{
                    showErrorMessage(title: "Word used already", message: "Be more original!")
                }
            }else {
                guard let title = title?.lowercased() else {return}
                showErrorMessage(title: "Word not possible", message: "You can't spell that word from \(title)")
            }
            
        }else {
            showErrorMessage(title: "Wrong answer", message: "Word is short or same as start word")
        }
        
        
        
        
    }
    
    
    func showErrorMessage(title: String, message: String) {
        
        
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(ac, animated: true, completion: nil)
        
    }
    
    
    func isNotShortOrSameAsStartWord(word: String) -> Bool {
        
        guard let startWord = title?.lowercased() else {return false}
        
        if word.count < 3 {
            return false
        }else if word == startWord {
            return false
        }
        return true
        
        
    }
    
    func isPossible(word: String) -> Bool {
        guard var tempWord = title?.lowercased() else { return false }
        
        for letter in word {
            if let position = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: position)
            } else {
                return false
            }
        }
        
        return true
    }
    
    
    
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    func isReal(word: String) -> Bool {
        
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        return misspelledRange.location == NSNotFound
        
        
    }
    
    @objc func startGame() {
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "word", for: indexPath)
        
        cell.textLabel?.text = usedWords[indexPath.row]
        return cell
    }
    
  
}

