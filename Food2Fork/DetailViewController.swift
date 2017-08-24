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
    var detailRecipe: DetailRecipe?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = recipe?.title
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.foodWhite]
        
        self.tableView.backgroundColor = .foodBlack
        self.tableView.tableHeaderView = UIImageView()
        
        getRecipeFromFood2Fork()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let recipeImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 300))
        let imageURL = URL(string: (recipe?.imageUrlString)!)
        self.tableView.tableHeaderView = recipeImageView
        recipeImageView.contentMode = .scaleAspectFit
        
        performTaskInBackground() {
            if let imageData = try? Data(contentsOf: imageURL!) {
                performUIUpdatesOnMain {
                    recipeImageView.image = UIImage(data: imageData)
                }
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return Constants.StringLiterals.Ingredients
        case 1:
            return Constants.StringLiterals.PublisherName
        case 2:
            return Constants.StringLiterals.PublisherUrl
        default:
            return Constants.StringLiterals.F2FUrl
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return detailRecipe?.ingredients.count ?? 0
        default:
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = .foodDarkBlack
        } else {
            cell.backgroundColor = .foodBlack
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(UITableViewCell.self, for: indexPath)
        
        switch indexPath.section {
        case 0:
            cell.textLabel?.text = detailRecipe?.ingredients[indexPath.row]
        case 1:
            cell.textLabel?.text = detailRecipe?.publisherName
        case 2:
            cell.textLabel?.text = detailRecipe?.publisherUrl
        default:
            cell.textLabel?.text = detailRecipe?.food2ForkUrlString
        }
        
        return cell
    }
    
    // MARK: Network request
    fileprivate func getRecipeFromFood2Fork() {
        let parameters = [Constants.Food2ForkParameterKeys.RecipeId: recipe?.recipeId as AnyObject]
        let method = Constants.Food2ForkMethods.Get
        
        let netwotkClient = NetworkClient()
        
        netwotkClient.taskForGETMethod(method: method, parameters: parameters) { (result, error) in
            guard let result = result else {
                print("\(String(describing: error))")
                return
            }
            
            let detailRecipe = DetailRecipe.createDetailRecipe(recipeDictionary: result)
            
            performUIUpdatesOnMain {
                self.detailRecipe = detailRecipe
                self.tableView.reloadData()
            }
        }
    }
}

