# -*- encoding: utf-8 -*-
module Gis::Script::Geocoding

  def self.get_point(address)
    return {} if address.blank?
    hash = {}
    begin
       address = URI.encode(address)
       hash = Hash.new
       baseUrl = "http://maps.google.com/maps/api/geocode/json"
       reqUrl = "#{baseUrl}?address=#{address}&sensor=false&language=ja"
       response = Net::HTTP.get_response(URI.parse(reqUrl))
       status = JSON.parse(response.body)
       hash[:lat] = status['results'][0]['geometry']['location']['lat']
       hash[:lng] = status['results'][0]['geometry']['location']['lng']
    rescue => e
      dump e
      return nil
    end
     return hash
  end


end