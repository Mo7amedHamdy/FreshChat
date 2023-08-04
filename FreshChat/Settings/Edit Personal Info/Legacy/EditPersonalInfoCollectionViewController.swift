//
//  EditPersonalInfoCollectionViewController.swift
//  FreshChat
//
//  Created by Mohamed Hamdy on 26/06/2023.
//

import UIKit

var ok: Bool!

class EditPersonalInfoCollectionViewController: UICollectionViewController {

    //type alias for diffable data source and snapshot
    typealias Datasource = UICollectionViewDiffableDataSource<Section, Row>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Row>
    
    var personalInfo: PersonalInformation!
            
    var datasource: Datasource!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = configureCompositionalList()
        collectionView.collectionViewLayout = layout
        
        datasource = configuerDatasource()
        
        configureSnapshot()
        
        navigationItem.title = "Edit Profile"
        navigationController?.navigationBar.topItem?.backButtonDisplayMode = .minimal

    }
    
    //configure collection view compositional layout
    func configureCompositionalList() -> UICollectionViewCompositionalLayout {
        let list = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        let layout = UICollectionViewCompositionalLayout.list(using: list)
        return layout
    }
    
    
    //cell Registeration
    func configureRegisteredCell() -> UICollectionView.CellRegistration<UICollectionViewListCell, Row> {
        //cell registeration
        let registeredCell = UICollectionView.CellRegistration<UICollectionViewListCell, Row> { cell, indexPath, item in
            //TODO configure cell
            let section = self.getSection(indexPath: indexPath)
            switch(section) {
            case .profileImage :
                let content = self.configureProfilePictureRow(for: cell, with: item)
                cell.contentConfiguration = content
            case .name :
                let content = self.configureNameRow(for: cell, with: item)
                cell.contentConfiguration = content
            }
        }
        
        return registeredCell
    }
    
    func getSection(indexPath: IndexPath) -> Section {
        let sectionNumber = indexPath.section
        guard let section = Section(rawValue: sectionNumber) else { fatalError("Unable to find matching section") }
        return section
    }
    
    func configureProfilePictureRow(for cell:UICollectionViewListCell, with item: Row) -> UIContentConfiguration {
        var content = cell.contentViewCellConfigurationForProfilePic()
        content.profileInfo = self.personalInfo
        cell.contentConfiguration = content
        return content
    }
    
    func configureNameRow(for cell:UICollectionViewListCell, with item: Row) -> UIContentConfiguration? {
        var content = cell.contentViewCellConfigurationForProfileName()
        content.profileInfo = self.personalInfo
        content.onActive = { isFirstRes in
            if isFirstRes == true {
                //TODO add done button and cancel button to navigation bar
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.acceptNameChange))
                self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.declineNameChange))
            }
        }
        cell.contentConfiguration = content
        
        return content
    }
    
    //name changes funcs
    @objc func acceptNameChange() {
        ok = true
        cancelEditName()
    }
    
    @objc func declineNameChange() {
        ok = false
        cancelEditName()
    }
    
    //cancel edit name mode
    func cancelEditName() {
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.leftBarButtonItem = nil
        view.endEditing(true)
    }
    
    //configure diffable data source
    func configuerDatasource() -> Datasource {
        let registeredCell = self.configureRegisteredCell()
        return .init(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            return collectionView.dequeueConfiguredReusableCell(using: registeredCell, for: indexPath, item: itemIdentifier)
        }
    }
    
    //configure snapshot
    func configureSnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections([.profileImage, .name])
        snapshot.appendItems([.profileImage], toSection: .profileImage)
        snapshot.appendItems([.name], toSection: .name)
        datasource.apply(snapshot)
    }
}
