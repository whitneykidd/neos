require 'faraday'
require 'figaro'
require 'pry'
# Load ENV vars via Figaro
Figaro.application = Figaro::Application.new(environment: 'production', path: File.expand_path('../config/application.yml', __FILE__))
Figaro.load

class NearEarthObjects

  def initialize(date)
    conn = Faraday.new(
          url: 'https://api.nasa.gov',
          params: { start_date: date, api_key: ENV['nasa_api_key']})

    asteroids_list_data = conn.get('/neo/rest/v1/feed')
    @parsed_asteroids_data = JSON.parse(asteroids_list_data.body, symbolize_names: true)[:near_earth_objects][:"#{date}"]
  end

  def largest_asteroid_diameter
    @parsed_asteroids_data.map do |asteroid|
      asteroid[:estimated_diameter][:feet][:estimated_diameter_max].to_i
    end.max { |a,b| a<=> b}
  end

  def total_number_of_asteroids
    @parsed_asteroids_data.count
  end

  def formatted_asteroid_data
    @parsed_asteroids_data.map do |asteroid|
        {
          name: asteroid[:name],
          diameter: "#{asteroid[:estimated_diameter][:feet][:estimated_diameter_max].to_i} ft",
          miss_distance: "#{asteroid[:close_approach_data][0][:miss_distance][:miles].to_i} miles"
        }
      end
  end

  def asteroid_details
    {
      asteroid_list: formatted_asteroid_data,
      biggest_asteroid: largest_asteroid_diameter,
      total_number_of_asteroids: total_number_of_asteroids
    }
  end
end
