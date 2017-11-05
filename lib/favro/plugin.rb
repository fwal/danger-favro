module Danger
  # This is a danger plugin that detects Favro tickets in added code and pr titles
  #
  # @example Initiate the check
  #
  #          favro.check(
  #            user_name: "api-user",
  #            api_token: "api-token",
  #            organization_id: "org-id",
  #            key: "Test"
  #          )
  #
  # @example Environment variables can also be used.
  #
  #          ENV["DANGER_FAVRO_USER_NAME"] = "api-user"
  #          ENV["DANGER_FAVRO_API_TOKEN"] = "api-token"
  #          ENV["DANGER_FAVRO_ORGANIZATION_ID"] = "org-id"
  #
  #          favro.check(key: "Test")
  #
  #
  # @see  /danger-favro
  # @tags favro issues tickets
  class DangerFavro < Plugin
    # Check for tickets.
    #
    # @param [String] user_name
    # @param [String] api_token
    # @param [String] organization_id
    # @param [String] key
    # @return   [void]
    def check(user_name: nil, api_token: nil, organization_id: nil, key: nil)
      return unless setup(user_name, api_token, organization_id, key)

      ids = find_ticket_ids([title] + file_additions)

      return if ids.empty?

      client = ApiClient.new(@user_name, @api_token, @organization_id)
      tickets = client.get(ids)

      render_table(tickets)
    end

    private

    def setup(user_name, api_token, organization_id, key)
      @user_name = user_name || ENV["DANGER_FAVRO_USER_NAME"]
      @api_token = api_token || ENV["DANGER_FAVRO_API_TOKEN"]
      @organization_id = organization_id || ENV["DANGER_FAVRO_ORGANIZATION_ID"]
      @key = key || ENV["DANGER_FAVRO_KEY"]
      @issue_pattern = /(?<ticket>(#{@key})-(\d+))+/i

      is_valid = true
      if @user_name.nil? || @user_name.empty?
        is_valid = false
        fail("Danger Favro plugin: Missing `user_name`")
      end

      if @api_token.nil? || @api_token.empty?
        is_valid = false
        fail("Danger Favro plugin: Missing `api_token`")
      end

      if @organization_id.nil? || @organization_id.empty?
        is_valid = false
        fail("Danger Favro plugin: Missing `organization_id`")
      end

      if @key.nil? || @key.empty?
        is_valid = false
        fail("Danger Favro plugin: Missing `key`")
      end

      is_valid
    end

    def title
      case danger.scm_provider
      when :github
        github.pr_title
      when :bitbucket_server
        bitbucket_server.pr_title
      when :bitbucket_cloud
        bitbucket_cloud.pr_title
      when :vsts
        vsts.pr_title
      when :gitlab
        gitlab.mr_title
      end
    end

    def file_additions
      additions = []
      (git.modified_files + git.added_files).each do |file|
        additions += git.diff_for_file(file).patch.scan(/^\+.+/)
      end
      additions
    end

    def find_ticket_ids(list)
      matches = []

      list.each do |item|
        matches += item.scan(@issue_pattern).flatten
      end

      matches.uniq.collect(&:upcase)
    end

    def render_table(tickets)
      table = "
<table>
  <thead>
    <tr>
      <th width=\"10%\">
      </th>
      <th width=\"50%\">
        #{tickets.length} Favro ticket#{tickets.length > 1 ? 's' : ''} referenced
      </th>
    </tr>
  </thead>
  <tbody>
"
      table << tickets.map { |ticket| render_row(ticket) }.join("\n")
      table << "
  </tbody>
</table>"

      markdown table
    end

    def render_row(ticket)
      "   <tr>
      <td><a href=\"https://favro.com/card/#{@organization_id}/#{ticket.id}\">#{ticket.id}</a></td>
      <td>#{ticket.name}</td>
    </tr>"
    end
  end
end
