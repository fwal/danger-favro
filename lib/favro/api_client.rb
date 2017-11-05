require "rest-client"

module Danger
  class ApiClient
    def initialize(user_name, api_token, organization_id)
      @user_name = user_name
      @api_token = api_token
      @organization_id = organization_id
    end

    def get(ticket_ids)
      tickets = []
      ticket_ids.each do |id|
        response = request(id)
        tickets << Ticket.new(id, response.nil? ? nil : response["entities"][0]["name"])
      end
      tickets
    end

    private

    def request(ticket_id)
      response = RestClient::Request.execute method: :get, url: "https://favro.com/api/v1/cards?cardSequentialId=#{ticket_id}&unique=true&limit=1", headers: { accept: :json, organizationId: @organization_id }, user: @user_name, password: @api_token
      JSON.parse(response)
    end
  end
end
