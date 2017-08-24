//
//  ViewController.swift
//  Food2Fork
//
//  Created by Utheim Sverdrup, Ulrik on 16.08.2017.
//  Copyright © 2017 Utheim Sverdrup, Ulrik. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController, UISearchBarDelegate {
    
    var searchController: UISearchController!
    var recipeToPass: ListRecipe?
    
    private var emptySearchView: EmptySearchView {
        return self.view as! EmptySearchView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let emptySearchView = UIView.instanceFromNib() as EmptySearchView
        self.tableView.backgroundView = emptySearchView
        
        self.searchController = UISearchController(searchResultsController: nil)
        self.navigationItem.titleView = self.searchController.searchBar
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.searchBar.keyboardAppearance = .alert
        self.searchController.dimsBackgroundDuringPresentation = false
        tableView.separatorStyle = .none
        
        navigationController?.navigationBar.barTintColor = .foodBlack
        navigationController?.navigationBar.tintColor = .foodGreen
        self.tableView.separatorColor = .foodDarkBlack
        
        self.tableView.registerNib(CustomRecipeCell.self)
        self.tableView.backgroundColor = .foodBlack
        definesPresentationContext = true

        self.searchController.searchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    // MARK: Search Bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        
        guard let searchBarText = searchController.searchBar.text else {
            return
        }
        
        if searchBarText.isEmpty {
            RecipesProvider.sharedProvider.listRecipes = []
            tableView?.backgroundView?.isHidden = false
            tableView?.reloadData()
        } else {
            perform(#selector(getRecipeFromFood2ForkBySearch), with: nil, afterDelay: 1.0)
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.text = RecipesProvider.sharedProvider.lastSearchString   // Keep text from former search
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        RecipesProvider.sharedProvider.lastSearchString = searchBar.text!  // Store searchPhrase
    }
    
    // MARK: Table View
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if RecipesProvider.sharedProvider.listRecipes.count == 0 {
            self.tableView?.backgroundView?.isHidden = false
        } else {
            self.tableView?.backgroundView?.isHidden = true
        }
        
        return RecipesProvider.sharedProvider.listRecipes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(CustomRecipeCell.self, for: indexPath)
        
        let recipeImage = RecipesProvider.sharedProvider.listRecipes[indexPath.row]
        let imageURL = URL(string: recipeImage.imageUrlString)
        
        cell.recipeImage?.image = UIImage()
        cell.recipeTitleLabel?.text = recipeImage.title
        
        performTaskInBackground() {
            if let imageData = try? Data(contentsOf: imageURL!) {
                performUIUpdatesOnMain {
                    cell.recipeImage?.image = UIImage(data: imageData)
                }
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let recipe = RecipesProvider.sharedProvider.listRecipes[indexPath.row]
        recipeToPass = recipe
        
        performSegue(withIdentifier: Constants.StringLiterals.SegueIdentifier, sender: self)
    }
    
    // MARK: Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == Constants.StringLiterals.SegueIdentifier)
        {
            let viewController = segue.destination as! DetailViewController
            viewController.recipe = recipeToPass
        }
    }
    
    // MARK: Network request
    @objc fileprivate func getRecipeFromFood2ForkBySearch() {
        guard let searchBarText = searchController.searchBar.text else {
            return
        }
        
        RecipesProvider.sharedProvider.getRecipeFromFood2ForkBySearch(searchPhrase: searchBarText) {
            if RecipesProvider.sharedProvider.listRecipes.count == 0 {
                print("No recipes found. Search again.")
                self.presentNoSearchResultAlert()
                return
            } else {
                self.tableView?.reloadData()
            }
        }
    }
    
    func presentNoSearchResultAlert() {
        // Create the alert controller
        let alertController = UIAlertController(title: "No search result for:", message: "\(RecipesProvider.sharedProvider.lastSearchString ?? "")", preferredStyle: .alert)
        
        alertController.view.tintColor = .foodGreen
        alertController.view.backgroundColor = .foodBlack
        alertController.view.layer.cornerRadius = 25
        
        // Create the actions
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.cancel) { alert in
            
        }
        
        // Add the actions
        alertController.addAction(okAction)
        
        // Present the controller
        self.present(alertController, animated: true, completion: nil)
    }
}

