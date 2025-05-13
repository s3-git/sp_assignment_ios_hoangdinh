//
//  WeatherServicesProtocol.swift
//  BivWeatherAssignment
//
//  Created by hoang.dinh on 5/12/25.
//

import Combine

protocol WeatherServiceProtocol {
    func searchCities(query: WeatherSearchRequestParameters) -> AnyPublisher<[SearchResult], NetworkError>
    func getWeather(query: WeatherRequestParameters, forceRefresh: Bool) -> AnyPublisher<WeatherData, NetworkError>
    func clearAllCaches()
}
