//
//  FormPresenter.swift
//  Bog Assignment
//
//  Created by nikoloz on 16.03.18.
//  Copyright © 2018 Mobility LLC. All rights reserved.
//

import Foundation

protocol CollectionItemView {
    func display(icon: String)
    func display(title: String)
}

protocol SectionCollectionTableCellView {
    func display(title:String)
}

protocol OperationCellView {
    func display(icon: String)
    func display(title: String)
    func display(time: String)
    func display(id: String)
    func display(amount: String)
}

protocol FormView: class {
    func resfreshTableView()
    func displayDataFetchError(_ error: Error)
}

protocol FormPresenter {
    var  numberOfSections:Int { get }
    func configure(cell: OperationCell, for indexPath: IndexPath)
    func configure(cell: SectionCollectionTableCell, for indexPath: IndexPath)
    func configure(cell: CollectionItemCell, with tag: Int, for indexPath: IndexPath)
    func numberOfRows(in section: Int) -> Int
    func numnberOfcollectionItems(in section: Int, forRow row: Int) -> Int
    func rowHeight(for section: Int) -> Float
    func typeFor(section: Int) -> SectionType
    func viewDidLoad()
}

class FormPresenterImplementation: FormPresenter {
    
    fileprivate weak var view: FormView?
    fileprivate let displaySectionsUseCase: DisplaySectionsUseCase?
    var items = [SectionViewModel]()
    
    init(view: FormView?, displaySectionsUseCase: DisplaySectionsUseCase?) {
        self.view = view
        self.displaySectionsUseCase = displaySectionsUseCase
    }
    
    var numberOfSections: Int {
        return items.count
    }
    
    func viewDidLoad() {
        self.displaySectionsUseCase?.displaySections(completionHandler: { (result) in
            switch result {
            case let .success(items):
                self.handleFetchedItems(items)
            case let .failure(error):
                self.handleFetchError(error)
            }
        })
    }
    
    func handleFetchedItems(_ items: [SectionViewModel]) {
        self.items = items
        view?.resfreshTableView()
    }
    
    func handleFetchError(_ error: Error) {
        view?.displayDataFetchError(error)
    }
    
    func configure(cell: OperationCell, for indexPath: IndexPath) {
        let sectionListModelItem = items[indexPath.section] as! SectionListViewModel
        let operation = sectionListModelItem.items[indexPath.row]
        
        cell.display(id: operation.id)
        cell.display(icon: operation.icon)
        cell.display(time: operation.time)
        cell.display(title: operation.title)
        cell.display(amount: operation.amount + " e")
    }
    
    func configure(cell: SectionCollectionTableCell, for indexPath: IndexPath) {
        guard let collectionViewModel = items.item(at: indexPath.section) as? SectionCollectionViewModel,
              let model = collectionViewModel.items.item(at: indexPath.row) else {
            return
        }
        
        cell.display(title: model.sectionTitle)
    }
    
    func configure(cell: CollectionItemCell, with tag: Int, for indexPath: IndexPath) {
        guard let sectionCollectionViewModel = items.item(at: Helpers.sectionFromTag(tag: tag)) as? SectionCollectionViewModel,
            let model = sectionCollectionViewModel.items.item(at: Helpers.rowFromTag(tag: tag)),
            let item = model.items.item(at: indexPath.row) else {
                return
        }
        
        cell.display(icon: item.icon)
        cell.display(title: item.title)
    }
    
    func numnberOfcollectionItems(in section: Int, forRow row: Int) -> Int {
        guard let sectionCollectionViewModel = items.item(at: section) as? SectionCollectionViewModel,
              let model = sectionCollectionViewModel.items.item(at: row) else {
                return 0
        }
    
        return model.items.count
    }
    
    func numberOfRows(in section: Int) -> Int {
        return items[section].rowCount
    }
    
    func typeFor(section: Int) -> SectionType {
        return items[section].type
    }
    
    func rowHeight(for section: Int) -> Float {
        return items[section].rowHeight
    }
    
}
