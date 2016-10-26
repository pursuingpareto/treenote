//
//  PagedTableViewDataSource.swift
//  PagedTableView
//
//  Created by Andrew Brown on 10/20/16.
//  Copyright © 2016 Andrew Brown. All rights reserved.
//

import UIKit

protocol PagedTableViewControllerDataSource {
    func numberOfPages(in: PagedTableViewController) -> Int
    func pagedTableViewController(_ pagedTableViewController: PagedTableViewController, numberOfSectionsOnPage page: Int) -> Int
    func pagedTableViewController(_ pagedTableViewController: PagedTableViewController, numberOfRowsInSection section: Int, onPage page: Int) -> Int
    func pagedTableViewController(_ pagedTableViewController: PagedTableViewController, cellForRowAt indexPath: IndexPath, onPage page: Int) -> UITableViewCell
}
