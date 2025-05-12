import Foundation

// MARK: - WeatherModel
struct WeatherModel: Codable {
    let data: WeatherData?
}

// MARK: - DataClass
struct WeatherData: Codable {
    let request: [Request]?
    let nearestArea: [NearestArea]?
    let timeZone: [TimeZone]?
    let currentCondition: [CurrentCondition]?
    let weather: [Weather]?
    let climateAverages: [ClimateAverage]?

    init(request: [Request]? = [], nearestArea: [NearestArea]? = [], timeZone: [TimeZone]? = [], currentCondition: [CurrentCondition]? = [], weather: [Weather]? = [], climateAverages: [ClimateAverage]? = []) {
        self.request = request
        self.nearestArea = nearestArea
        self.timeZone = timeZone
        self.currentCondition = currentCondition
        self.weather = weather
        self.climateAverages = climateAverages
    }

    enum CodingKeys: String, CodingKey {
        case request
        case nearestArea = "nearest_area"
        case timeZone = "time_zone"
        case currentCondition = "current_condition"
        case weather
        case climateAverages = "ClimateAverages"
    }
}

// MARK: - ClimateAverage
struct ClimateAverage: Codable {
    let month: [Month]?
}

// MARK: - Month
struct Month: Codable {
    let index, name, avgMinTemp, avgMinTempF: String?
    let absMaxTemp, absMaxTempF, avgDailyRainfall: String?

    enum CodingKeys: String, CodingKey {
        case index, name, avgMinTemp
        case avgMinTempF = "avgMinTemp_F"
        case absMaxTemp
        case absMaxTempF = "absMaxTemp_F"
        case avgDailyRainfall
    }
}

// MARK: - CurrentCondition
struct CurrentCondition: Codable {
    let observationTime, tempC, tempF, weatherCode: String?
    let weatherIconURL, weatherDesc: [WeatherDesc]?
    let windspeedMiles, windspeedKmph, winddirDegree, winddir16Point: String?
    let precipMM, precipInches, humidity, visibility: String?
    let visibilityMiles, pressure, pressureInches, cloudcover: String?
    let feelsLikeC, feelsLikeF, uvIndex: String?

    enum CodingKeys: String, CodingKey {
        case observationTime = "observation_time"
        case tempC = "temp_C"
        case tempF = "temp_F"
        case weatherCode
        case weatherIconURL = "weatherIconUrl"
        case weatherDesc, windspeedMiles, windspeedKmph, winddirDegree, winddir16Point, precipMM, precipInches, humidity, visibility, visibilityMiles, pressure, pressureInches, cloudcover
        case feelsLikeC = "FeelsLikeC"
        case feelsLikeF = "FeelsLikeF"
        case uvIndex
    }
}

// MARK: - WeatherDesc
struct WeatherDesc: Codable {
    let value: String?
}

// MARK: - NearestArea
struct NearestArea: Codable {
    let areaName, country, region: [WeatherDesc]?
    let latitude, longitude, population: String?
    let weatherURL: [WeatherDesc]?

    enum CodingKeys: String, CodingKey {
        case areaName, country, region, latitude, longitude, population
        case weatherURL = "weatherUrl"
    }
}

// MARK: - Request
struct Request: Codable {
    let type, query: String?
}

// MARK: - TimeZone
struct TimeZone: Codable {
    let localtime, utcOffset, zone: String?
}

// MARK: - Weather
struct Weather: Codable {
    let date: String?
    let astronomy: [Astronomy]?
    let maxtempC, maxtempF, mintempC, mintempF: String?
    let avgtempC, avgtempF, totalSnowCM, sunHour: String?
    let uvIndex: String?
    let hourly: [Hourly]?

    enum CodingKeys: String, CodingKey {
        case date, astronomy, maxtempC, maxtempF, mintempC, mintempF, avgtempC, avgtempF
        case totalSnowCM = "totalSnow_cm"
        case sunHour, uvIndex, hourly
    }
}

// MARK: - Astronomy
struct Astronomy: Codable {
    let sunrise, sunset, moonrise, moonset: String?
    let moonPhase, moonIllumination: String?

    enum CodingKeys: String, CodingKey {
        case sunrise, sunset, moonrise, moonset
        case moonPhase = "moon_phase"
        case moonIllumination = "moon_illumination"
    }
}

// MARK: - Hourly
struct Hourly: Codable {
    let time, tempC, tempF, windspeedMiles: String?
    let windspeedKmph, winddirDegree, winddir16Point, weatherCode: String?
    let weatherIconURL, weatherDesc: [WeatherDesc]?
    let precipMM, precipInches, humidity, visibility: String?
    let visibilityMiles, pressure, pressureInches, cloudcover: String?
    let heatIndexC, heatIndexF, dewPointC, dewPointF: String?
    let windChillC, windChillF, windGustMiles, windGustKmph: String?
    let feelsLikeC, feelsLikeF, chanceofrain, chanceofremdry: String?
    let chanceofwindy, chanceofovercast, chanceofsunshine, chanceoffrost: String?
    let chanceofhightemp, chanceoffog, chanceofsnow, chanceofthunder: String?
    let uvIndex, shortRAD, diffRAD: String?

    enum CodingKeys: String, CodingKey {
        case time, tempC, tempF, windspeedMiles, windspeedKmph, winddirDegree, winddir16Point, weatherCode
        case weatherIconURL = "weatherIconUrl"
        case weatherDesc, precipMM, precipInches, humidity, visibility, visibilityMiles, pressure, pressureInches, cloudcover
        case heatIndexC = "HeatIndexC"
        case heatIndexF = "HeatIndexF"
        case dewPointC = "DewPointC"
        case dewPointF = "DewPointF"
        case windChillC = "WindChillC"
        case windChillF = "WindChillF"
        case windGustMiles = "WindGustMiles"
        case windGustKmph = "WindGustKmph"
        case feelsLikeC = "FeelsLikeC"
        case feelsLikeF = "FeelsLikeF"
        case chanceofrain, chanceofremdry, chanceofwindy, chanceofovercast, chanceofsunshine, chanceoffrost, chanceofhightemp, chanceoffog, chanceofsnow, chanceofthunder, uvIndex
        case shortRAD = "shortRad"
        case diffRAD = "diffRad"
    }
}
