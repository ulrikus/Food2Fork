//
//  DetailViewController.swift
//  Food2Fork
//
//  Created by Utheim Sverdrup, Ulrik on 17.08.2017.
//  Copyright © 2017 Utheim Sverdrup, Ulrik. All rights reserved.
//

import UIKit

class DetailViewController: UITableViewController {
    
    var recipe: ListRecipe?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = recipe?.title
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.foodWhite]
        
        self.tableView.backgroundColor = .foodBlack
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.StringLiterals.ReuseCellIdentifier)!
        
        cell.textLabel?.text = "Test \(indexPath.row+1)"
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let recipeImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 375, height: 50))
        let imageURL = URL(string: (recipe?.imageUrlString)!)
        
        performTaskInBackground() {
            if let imageData = try? Data(contentsOf: imageURL!) {
                performUIUpdatesOnMain {
                    recipeImageView.image = UIImage(data: imageData)
                }
            }
        }
        return UIView()
    }
}

