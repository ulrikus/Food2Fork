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
    var resultsController = UITableViewController()
    var searchPhrase = String()
    var recipes = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.resultsController.tableView.dataSource = self
        self.resultsController.tableView.delegate = self
        
        self.searchController = UISearchController(searchResultsController: self.resultsController)
        self.navigationItem.titleView = self.searchController.searchBar

        navigationController?.navigationBar.barTintColor = UIColor.black
        
        self.tableView.registerNib(CustomRecipeCell.self)
        self.resultsController.tableView.register(CustomRecipeCell.self)
        definesPresentationContext = true

        self.searchController.searchBar.delegate = self
    }
    
    // MARK: Search Bar
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.text = searchPhrase   // Keep text from former search
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchPhrase = searchBar.text!  // Store searchPhrase
    }
    
    // MARK: Table View
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(CustomRecipeCell.self, for: indexPath)
        
        cell.recipeTitleLabel.text = "Test \(indexPath.row+1)"
        
        if indexPath.row % 2 == 0 {
            cell.recipeImage.image = #imageLiteral(resourceName: "testImageRecipe")
        } else {
            cell.recipeImage.image = #imageLiteral(resourceName: "testImageRecipe3")
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}

