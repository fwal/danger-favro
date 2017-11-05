require "rest-client"

module Danger
  class ApiClient
    def initialize(user_name, api_token, organization_id)
      @user_name = user_name
      @api_token = api_token
      @organization_id = organization_id
    end

    def get(card_ids)
      cards = []
      card_ids.each do |id|
        response = request(id)
        cards << Card.new(id, response.nil? ? "<i>(unknown)</i>" : response["entities"][0]["name"])
      end
      cards
    end

    private

    def request(card_id)
      response = RestClient::Request.execute method: :get, url: "https://favro.com/api/v1/cards?cardSequentialId=#{card_id}&unique=true&limit=1", headers: { accept: :json, organizationId: @organization_id }, user: @user_name, password: @api_token
      JSON.parse(response)
    rescue RestClient::ExceptionWithResponse
      nil
    end
  end
end
