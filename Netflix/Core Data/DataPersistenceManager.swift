//
//  DataPersistenceManager.swift
//  Netflix
//
//  Created by ziad on 23/02/2022.
//

import Foundation
import UIKit
import CoreData


class DataPersistenceManager{
    enum DataPersistenceError: Error{
        case failedToSaveData
        case failedFetchData
        case faieldToDeleteData
    }
    static let shared = DataPersistenceManager()
    
    // MARK: - Save data in Data Base
    func downloadTitle(model : Title, completion : @escaping (Result<Void, Error>) -> Void){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{return}
        let context = appDelegate.persistentContainer.viewContext
        let item = TitleItem(context: context)
        item.original_title = model.original_title
        item.original_name = model.original_name
        item.id = Int64(model.id)
        item.overview = model.overview
        item.media_type = model.media_type
        item.poster_path = model.poster_path
        item.release_date = model.release_date
        item.vote_count = Int64(model.vote_count)
        item.vote_average = model.vote_average
        
        do{
            try context.save()
            completion(.success(()))
        }catch{
            completion(.failure(DataPersistenceError.failedToSaveData))
        }
    }
    // MARK: - Fetch data from Data Base
    func fetchingTitlesFromDataBase(completion: @escaping (Result<[TitleItem], Error>) -> Void){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{return}
        let context = appDelegate.persistentContainer.viewContext
        let request : NSFetchRequest<TitleItem>
        request = TitleItem.fetchRequest()
        do{
           let titles =  try context.fetch(request)
            completion(.success(titles))
        }catch{
            completion(.failure(DataPersistenceError.failedFetchData))
        }
    }
    
    // MARK: - Delete data from Data Base
    
    func deleteDataFromDataBase(model: TitleItem, completion: @escaping (Result<Void,Error>) -> Void){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else{return}
        let context = appDelegate.persistentContainer.viewContext
        context.delete(model)
        do{
            try context.save()
            completion(.success(()))
        }catch{
            completion(.failure(DataPersistenceError.faieldToDeleteData))
        }
    }
}
