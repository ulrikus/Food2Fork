//
//  DetailViewController.swift
//  Food2Fork
//
//  Created by Utheim Sverdrup, Ulrik on 17.08.2017.
//  Copyright © 2017 Utheim Sverdrup, Ulrik. All rights reserved.
//

import UIKit

class DetailViewController: UITableViewController {
    
    var passedRecipe: Recipe?
    var recipe: Recipe?
    private let recipesCoordinator = RecipesCoordinator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = passedRecipe?.title
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.foodWhite]
        
        self.tableView.backgroundColor = .foodBlack
        self.tableView.tableHeaderView = UIImageView()
        
        self.tableView.register(UITableViewCell.self)
        
        getRecipe()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let recipeImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 300))
        self.tableView.tableHeaderView = recipeImageView
        recipeImageView.contentMode = .scaleAspectFit
        
        performTaskInBackground() { [weak self] in
            if let imageUrl = self?.passedRecipe?.imageUrl, let imageData = try? Data(contentsOf: imageUrl) {
                DispatchQueue.main.async {
                    recipeImageView.image = UIImage(data: imageData)
                }
            }
        }
    }
    
    // MARK: - TableView Data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let recipe = recipe, let ingredients = recipe.ingredients else {
            return 0
        }
        switch section {
        case 0:
            return ingredients.count
        default:
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(UITableViewCell.self, for: indexPath)
        
        guard let recipe = recipe, let ingredients = recipe.ingredients else {
            return cell
        }
        
        switch indexPath.section {
        case 0:
            cell.textLabel?.text = ingredients[indexPath.row]
        case 1:
            cell.textLabel?.text = recipe.publisher
        case 2:
            cell.textLabel?.text = recipe.publisherUrl.absoluteString
        default:
            cell.textLabel?.text = recipe.food2forkUrl.absoluteString
        }
        
        cell.textLabel?.textColor = .foodWhite
        
        return cell
    }
    
    // MARK: - TableView delegate
    
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
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = .foodDarkBlack
        } else {
            cell.backgroundColor = .foodBlack
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0: // Ingredients
            break
        case 1: // Name of publisher
            UIPasteboard.general.string = recipe?.publisher
            break
        case 2: // Base URL for publisher
            openUrlInSafari(url: recipe?.publisherUrl)
            break
        default: // URL of the recipe on Food2Fork.com
            openUrlInSafari(url: recipe?.food2forkUrl)
            break
        }
    }
    
    // MARK: - Actions
    
    private func openUrlInSafari(url: URL?) {
        guard let url = url else {
            return
        }
        UIApplication.shared.open(url, options: [:])
    }
    
    // MARK: - Network request
    
    fileprivate func getRecipe() {
        guard let recipeId = passedRecipe?.recipeId else {
            return
        }
        recipesCoordinator.getRecipe(with: recipeId) { [weak self] (recipe, error) in
            guard let recipe = recipe, error == nil else {
                return
            }
            DispatchQueue.main.async {
                self?.recipe = recipe
                self?.tableView.reloadData()
            }
        }
    }
}

