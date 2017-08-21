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
    var searchPhrase = String()
    var food2ForkImagesResult = [ListRecipe]()    // For storing image titles and URLs
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
        
        navigationController?.navigationBar.barTintColor = .foodBlack
        navigationController?.navigationBar.tintColor = .foodGreen
        self.tableView.separatorColor = .foodDarkBlack
        
        self.tableView.registerNib(CustomRecipeCell.self)
        self.tableView.backgroundColor = .foodBlack
        definesPresentationContext = true

        self.searchController.searchBar.delegate = self
    }
    
    // MARK: Search Bar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        
        searchPhrase = searchBar.text!
        if searchPhrase.isEmpty {
            food2ForkImagesResult = []
            tableView.backgroundView?.isHidden = false
            tableView.reloadData()
        } else {
            let methodParameters: [String: AnyObject] = [
                Constants.Food2ForkParameterKeys.SearchQuery: searchController.searchBar.text as AnyObject,
                Constants.Food2ForkParameterKeys.APIKey: Constants.Food2ForkParameterValues.APIKey as AnyObject
            ]
            perform(#selector(getRecipeFromFood2ForkBySearch), with: methodParameters, afterDelay: 1.0)
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.text = searchPhrase   // Keep text from former search
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchPhrase = searchBar.text!  // Store searchPhrase
    }
    
    // MARK: Table View
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return food2ForkImagesResult.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(CustomRecipeCell.self, for: indexPath)
        
        let recipeImage = food2ForkImagesResult[indexPath.row]
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
        
        let recipe = food2ForkImagesResult[indexPath.row]
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
    @objc fileprivate func getRecipeFromFood2ForkBySearch(_ methodParameters: [String: AnyObject]) {
        
        // Create session and request
        let session = URLSession.shared
        let request = URLRequest(url: food2ForkSearchURLFromParameters(methodParameters))
        
        // Create network request
        let task = session.dataTask(with: request) { (data, response, error) in
            
            func displayError(_ error: String) {
                print(error)
            }
            
            // GUARD: Was there an error?
            guard (error == nil) else {
                displayError("There was an error with your request: \(String(describing: error))")
                return
            }
            
            // GUARD: Did we get a successful 2XX response?
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                displayError("Your request returned a status code other than 2XX.")
                return
            }
            
            // GUARD: Was there any data returned?
            guard let data = data else {
                displayError("No data was returned by the request.")
                return
            }
            
            let parsedResult: [String: AnyObject]
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: AnyObject]
            } catch {
                displayError("Could not parse the data as JSON.")
                return
            }
            
            // GUARD: Is the "recipes" key in out result?
            guard let recipesArray = parsedResult[Constants.Food2ForkResponseKeys.Recipes] as? [[String: AnyObject]] else {
                displayError("Cannot find keys '\(Constants.Food2ForkResponseKeys.Recipes)' in \(parsedResult).")
                return
            }
            
            if recipesArray.count == 0 {
                self.tableView.backgroundView?.isHidden = false
                displayError("No recipes found. Search again.")
                return
            } else {
                var tempArray = [ListRecipe]()
                for recipe in recipesArray {
                    // GUARD: Does our image have a key for 'image_url'?
                    guard let imageURLString = recipe[Constants.Food2ForkResponseKeys.ImageUrl] as? String else {
                        displayError("Cannot find key '\(Constants.Food2ForkResponseKeys.ImageUrl)'")
                        continue
                    }
                    guard let recipeId = recipe[Constants.Food2ForkResponseKeys.RecipeId] as? String else {
                        displayError("Cannot find key '\(Constants.Food2ForkParameterKeys.RecipeId)'")
                        continue
                    }
                    
                    if let recipeTitle = recipe[Constants.Food2ForkResponseKeys.Title] as? String, recipeTitle != "" {
                        let image = ListRecipe(recipeId: recipeId, title: recipeTitle, imageUrlString: imageURLString)
                        tempArray.append(image)
                    } else {
                        let image = ListRecipe(recipeId: recipeId, title: "(Untitled)", imageUrlString: imageURLString)
                        tempArray.append(image)
                    }
                }
                performUIUpdatesOnMain {
                    self.food2ForkImagesResult = tempArray
                    self.tableView.backgroundView?.isHidden = true
                    self.tableView.reloadData()
                }
            }
        }
        
        // Start the task
        task.resume()
    }
    
    // MARK: Helper for Creating a URL from Parameters
    private func food2ForkSearchURLFromParameters(_ parameters: [String: AnyObject]) -> URL {
        var components = URLComponents()
        components.scheme = Constants.Food2Fork.APIScheme
        components.host = Constants.Food2Fork.APIHost
        components.path = Constants.Food2Fork.APIPathSearch
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        return components.url!
    }
}

