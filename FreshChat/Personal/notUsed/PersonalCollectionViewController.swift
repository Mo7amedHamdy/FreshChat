//
//  PersonalCollectionViewController.swift
//  FreshChat
//
//  Created by Mohamed Hamdy on 26/11/2022.
//

import UIKit


class PersonalCollectionViewController: UICollectionViewController {
    
    typealias Datasource = UICollectionViewDiffableDataSource<Int, String>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, String>

    var dataSource: Datasource!
    
    var itemsInSection0 = ["Sign Out"]
    
    var completeDismiss: (Bool) -> Void
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = configureDiffableDataSource()
        
        configureSnapshot()
        
    }
    
    
    init(completeDismiss: @escaping (Bool) -> Void) {
        self.completeDismiss = completeDismiss
        let list = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        let compositionalLayout = UICollectionViewCompositionalLayout.list(using: list)
        super.init(collectionViewLayout: compositionalLayout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    // registered cell configuration
    func configureRegisteredCell() -> UICollectionView.CellRegistration<UICollectionViewListCell, String> {
        return .init(handler: cellConfiguration(cell:indexPath:item:))
    }
    
    func cellConfiguration(cell: UICollectionViewListCell, indexPath: IndexPath, item: String) {
        var contentConfig = cell.defaultContentConfiguration()
        contentConfig.text = item
        contentConfig.textProperties.alignment = .center
        contentConfig.textProperties.color = .red
        cell.contentConfiguration = contentConfig
    }
    
    
    //configure diffable data source
    func configureDiffableDataSource() -> Datasource {
        let registeredCell = configureRegisteredCell()
        return Datasource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(using: registeredCell, for: indexPath, item: itemIdentifier)
        }
    }
    
    
    //configure snapshot
    func configureSnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(["Sign Out"], toSection: 0)
        dataSource.apply(snapshot)
    }

}
