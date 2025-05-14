//
//  WeatherServicesProtocol.swift
//  BivWeatherAssignment
//
//  Created by hoang.dinh on 5/12/25.
//

import Combine

protocol WeatherServiceProtocol {
    func searchCities(query: WeatherSearchRequestParameters) -> AnyPublisher<[SearchResult], AppError>
    func getWeather(query: WeatherRequestParameters, forceRefresh: Bool) -> AnyPublisher<WeatherData, AppError>
    func clearAllCaches()
}
