//
//  LoadMoreViewControllerType.swift
//  IssuesApp
//
//  Created by 강태훈 on 2018. 4. 28..
//  Copyright © 2018년 강태훈. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

protocol LoadMoreViewControllerType: class, ReactiveCompatible {
    
    associatedtype Cell: CellType & UICollectionViewCell
    associatedtype APIParameter
    
    var collectionView: UICollectionView! { get set }
    var disposeBag: DisposeBag { get set }
    var estimateCell: Cell { get set }
    var datasourceOut: BehaviorRelay<[Cell.Item]> { get set }
    var datasourceIn: PublishSubject<(APIParameter) -> Observable<[Cell.Item]>> { get set }
    var refreshControl : UIRefreshControl { get set }
    var nextPageID: BehaviorRelay<Int> { get set }
    var canLoadMore: BehaviorRelay<Bool> { get set }
    var loadMoreCell: LoadMoreCell? { get set }
    
    func apiCall(api: (APIParameter) -> Observable<[Cell.Item]>) -> Observable<[Cell.Item]>
    func headerView(collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView?
}

extension LoadMoreViewControllerType{
    
    func createDatasource() -> RxCollectionViewSectionedReloadDataSource<SectionModel<Int, Cell.Item>> {
        
        let datasource = RxCollectionViewSectionedReloadDataSource<SectionModel<Int, Cell.Item>>(configureCell: { (datasource, collectionView, indexPath, item) -> UICollectionViewCell in
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: Cell.self), for: indexPath) as? Cell else{
                return UICollectionViewCell()
            }
            cell.update(data: item)
            return cell
            
        }, configureSupplementaryView: { [weak self] (datasource, collectionView, kind, indexPath) -> UICollectionReusableView in
            
            guard let `self` = self else {return UICollectionReusableView()}
            
            switch kind{
                
            case UICollectionElementKindSectionHeader:
                let header = self.headerView(collectionView: collectionView, kind: kind, indexPath: indexPath) ?? UICollectionReusableView()
                return header
                
            case UICollectionElementKindSectionFooter:
                let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "LoadMoreCell", for: indexPath) as? LoadMoreCell ?? LoadMoreCell()
                self.loadMoreCell = footerView
                return footerView
            default:
                return UICollectionReusableView()
            }
        })
        
        return datasource
    }
}

extension LoadMoreViewControllerType {
    
    func sizeForItem(indexPath: IndexPath, collectionView: UICollectionView) -> CGSize{
        let models = datasourceOut.value
        let model = models[indexPath.item]
        estimateCell.update(data: model)
        let targetSize = CGSize(width: collectionView.frame.size.width, height: 50)
        let estimatedSize = estimateCell.contentView.systemLayoutSizeFitting(targetSize,
                                                                             withHorizontalFittingPriority: .required,
                                                                             verticalFittingPriority: .defaultLow) //모른다고함.. 그냥 쓰라함
        return estimatedSize
    }
}


extension LoadMoreViewControllerType {
    
    func nextPageIDBind(api: @escaping ((Int) -> (APIParameter) -> Observable<[Cell.Item]>)) {
        nextPageID.debug("nextPageID").map { pageID -> (APIParameter) -> Observable<[Cell.Item]> in
            return api(pageID)
        }.bind(to: datasourceIn)
        .disposed(by: disposeBag)
    }
    
    func datasourceInBind() {
        
        let refresh = Observable.combineLatest(datasourceOut, nextPageID) { (datasources, pageID) -> [Cell.Item] in
            if pageID == 1 { return [] }
            else { return datasources }
        }
        
        datasourceIn.flatMapFirst { [weak self] api -> Observable<[Cell.Item]> in
            guard let `self` = self else {return Observable.empty()}
            return self.apiCall(api: api)
            .do(onNext: { [weak self] _ in
                self?.refreshControl.endRefreshing()
                }, onError: { [weak self] _ in
                    self?.refreshControl.endRefreshing()
            })
            .retry()
            }.do(onNext: { [weak self] (models) in
                guard models.isEmpty else {return} //empty가 아니면 아무짓도 할 필요가 없다.
                self?.canLoadMore.accept(false)
            })
            
            .withLatestFrom(refresh, resultSelector: { (newModels, datasources) -> [Cell.Item] in
                return datasources + newModels
            }).bind(to: datasourceOut).disposed(by: disposeBag)
    }
    
    func datasourceOutBindtoCollectionView() {
        
        datasourceOut
            .map{
                [SectionModel<Int, Cell.Item>(model: 0, items: $0)]
            }.bind(to: collectionView.rx.items(dataSource: createDatasource()))
            .disposed(by: disposeBag)
    }

    func register(refreshControl: UIRefreshControl) {
        
        refreshControl.rx.controlEvent(.valueChanged)
            .map { _ in return () }
            .bind(to: rx.refresh)
            .disposed(by: disposeBag)
    }
    
    func registerLoadMore(collectionView: UICollectionView) {
        
        collectionView.rx.willDisplayCell.map { $1 }.withLatestFrom(datasourceOut, resultSelector: { (indexPath, datasources) -> (IndexPath, [Cell.Item]) in
            return (indexPath, datasources)
        })
            .filter{ (indexPath, datasources) -> Bool in
                return indexPath.item == datasources.count-1
            }.withLatestFrom(canLoadMore) //true인 경우에만 뒤로 넘겨준다.
            .filter{ $0 }
            .map { _ in return () }
            .bind(to: rx.loadMore).disposed(by: disposeBag)
    }
}

extension Reactive where Base: LoadMoreViewControllerType{
    var refresh: Binder<Void> {
        return Binder(base) { viewController, _ in
            viewController.nextPageID.accept(1)
            viewController.canLoadMore.accept(true)
        }
    }
    
    var loadMore: Binder<Void> {
        return Binder(base) { ViewController, _ in
            let pageID = ViewController.nextPageID.value
            ViewController.nextPageID.accept(pageID + 1)
        }
    }
}
