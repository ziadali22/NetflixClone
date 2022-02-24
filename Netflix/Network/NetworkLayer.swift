//
//  NetworkLayer.swift
//  Netflix
//
//  Created by ziad on 16/02/2022.
//

import Foundation
import UIKit
struct Constants {
    static let API_KEY = "697d439ac993538da4e3e60b54e762cd"
    static let baseURL = "https://api.themoviedb.org"
    static let YoutubeAPI_KEY = "AIzaSyDZ21U6FYFYOhJ-Y0syDp7iaEKgygO1JHA"
    static let YoutubeBaseURL = "https://youtube.googleapis.com/youtube/v3/search?"
}

enum APIError: Error {
    case failedTogetData
}


class ApiCaller{
    static let shared = ApiCaller()
    let group = DispatchGroup()
    // MARK: - Trending movies
    func getTrendingMovies(completion: @escaping (Result<[Title], Error>) -> Void ){
        group.enter()
        guard let url = URL(string: "\(Constants.baseURL)/3/trending/movie/day?api_key=\(Constants.API_KEY)") else {return}
        
        let task = URLSession.shared.dataTask(with: url) { data, _, err in
            guard let data = data, err == nil else {
                return
            }
            do{
                let result = try JSONDecoder().decode(TrendingTitleResponse.self, from: data)
                completion(.success(result.results))
                self.group.leave()
            }catch{
                completion(.failure(APIError.failedTogetData))
                self.group.leave()
            }
            
        }
        task.resume()
    }
    // MARK: - Trending TV
    func getTrendingTv(completion: @escaping (Result<[Title],Error>) -> Void){
        group.enter()
        guard let url =  URL(string: "\(Constants.baseURL)/3/trending/tv/day?api_key=\(Constants.API_KEY)") else {return}
        let task = URLSession.shared.dataTask(with: url) { data, _, err in
            guard let data = data, err == nil else {
                return
            }
            do{
                let result = try JSONDecoder().decode(TrendingTitleResponse.self, from: data)
                completion(.success(result.results))
                self.group.leave()
            }catch{
                completion(.failure(APIError.failedTogetData))
                self.group.leave()
            }
        }
        task.resume()
    }
    
    func getUpcomingMovies(completion: @escaping (Result<[Title], Error>) -> Void) {
        group.enter()
        guard let url = URL(string: "\(Constants.baseURL)/3/movie/upcoming?api_key=\(Constants.API_KEY)&language=en-US&page=1") else {return}
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            do {
                let results = try JSONDecoder().decode(TrendingTitleResponse.self, from: data)
                completion(.success(results.results))
                self.group.leave()
            } catch {
                print(error.localizedDescription)
                self.group.leave()
            }

        }
        task.resume()
    }
    
    func getPopular(completion: @escaping (Result<[Title], Error>) -> Void) {
        group.enter()
        guard let url = URL(string: "\(Constants.baseURL)/3/movie/popular?api_key=\(Constants.API_KEY)&language=en-US&page=1") else {return}
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            do {
                let results = try JSONDecoder().decode(TrendingTitleResponse.self, from: data)
                completion(.success(results.results))
                self.group.leave()
            } catch {
                completion(.failure(APIError.failedTogetData))
                self.group.leave()
            }
        }
        
        task.resume()
    }
    
    func getTopRated(completion: @escaping (Result<[Title], Error>) -> Void) {
        group.enter()
        guard let url = URL(string: "\(Constants.baseURL)/3/movie/top_rated?api_key=\(Constants.API_KEY)&language=en-US&page=1") else {return }
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            do {
                let results = try JSONDecoder().decode(TrendingTitleResponse.self, from: data)
                completion(.success(results.results))
                self.group.leave()

            } catch {
                completion(.failure(APIError.failedTogetData))
                self.group.leave()
            }

        }
        task.resume()
    }
    
    func getSearch(completion: @escaping (Result<[Title], Error>) -> Void){
        guard let url = URL(string: "\(Constants.baseURL)/3/discover/movie?api_key=\(Constants.API_KEY)&language=en-US&sort_by=popularity.desc&include_adult=false&include_video=false&page=1&with_watch_monetization_types=flatrate") else {return }
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            do{
                // decode
                let results = try JSONDecoder().decode(TrendingTitleResponse.self, from: data)
                completion(.success(results.results))
            }catch{
                completion(.failure(APIError.failedTogetData))
            }

        }
        task.resume()
    }
    
    func getSearchWithQueary(with query: String,completion : @escaping (Result<[Title], Error>) -> Void){
        guard let query = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return}
        guard let url =  URL(string: "\(Constants.baseURL)/3/search/movie?api_key=\(Constants.API_KEY)&query=\(query)")  else {return}
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data , error == nil else { return}
            do{
                //decode
                let result = try JSONDecoder().decode(TrendingTitleResponse.self, from: data)
                completion(.success(result.results))
            }catch {
                completion(.failure(APIError.failedTogetData))
            }
        }
        task.resume()
                
    }
    func getMoviesFromYoutube(with query : String, completion : @escaping (Result<VideoElement, Error>) -> Void){
        guard let query = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return}
        guard let url =  URL(string: "\(Constants.YoutubeBaseURL)q=\(query)&key=\(Constants.YoutubeAPI_KEY)")  else {return}
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data , error == nil else { return}
            do{
                //decode
                let result = try JSONDecoder().decode(YoutubeSearchResponse.self, from: data)
                completion(.success(result.items[0]))
                
            }catch {
                print(error.localizedDescription)
            }
        }
        task.resume()
    }
}
    
