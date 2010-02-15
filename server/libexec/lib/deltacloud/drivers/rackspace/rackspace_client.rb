#
# Copyright (C) 2009  Red Hat, Inc.
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

require "net/http"
require "net/https"
require 'rubygems'
require 'json'

#
# author: Michael Neale
# TODO: catch generic errors in JSON response and throw (probably)
#
module Deltacloud
  module Drivers
    module Rackspace

class RackspaceClient

  @@AUTH_API = URI.parse('https://auth.api.rackspacecloud.com/v1.0')

  def initialize(username, auth_key)
    http = Net::HTTP.new(@@AUTH_API.host,@@AUTH_API.port)
    http.use_ssl = true
    authed = http.get(@@AUTH_API.path, {'X-Auth-User' => username, 'X-Auth-Key' => auth_key})
    @auth_token  = authed.header['X-Auth-Token']
    @service_uri = URI.parse(authed.header['X-Server-Management-Url'])
    @service = Net::HTTP.new(@service_uri.host, @service_uri.port)
    @service.use_ssl = true
  end

  def get(path)
    @service.get(@service_uri.path + path, {"Accept" => "application/json", "X-Auth-Token" => @auth_token}).body
  end

  def list_flavors
    JSON.parse(get('/flavors/detail'))['flavors']
  end

  def list_images
    JSON.parse(get('/images/detail'))['images']
  end

  def list_servers
      JSON.parse(get('/servers/detail'))['servers']
  end


  def load_server_details( server_id )
    JSON.parse(get("/servers/#{server_id}"))['server']
  end


  def start_server(image_id, flavor_id, name)
    json = { :server => { :name => name, :imageId => image_id, :flavorId => flavor_id }}.to_json
    JSON.parse(@service.post(@service_uri.path + "/servers", json, headers).body)
  end

  def delete_server(server_id)
    @service.delete(@service_uri.path + "/servers/#{server_id}", headers)
  end

  def reboot_server(server_id)
    json = { :reboot => { :type => :SOFT }}.to_json
    @service.post(@service_uri.path + "/servers/#{server_id}/action", json, headers)
  end


  def headers
    {"Accept" => "application/json", "X-Auth-Token" => @auth_token, "Content-Type" => "application/json"}
  end

end

    end
  end
end




