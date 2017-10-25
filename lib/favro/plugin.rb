module Danger
  # @see  /danger-favro
  # @tags favro
  class DangerFavro < Plugin
    # Ticket key, the part that comes before the ticket number
    #
    # @return   [Array<String>]
    attr_accessor :key

    # A method that you can call from your Dangerfile
    # @return   [Array<String>]
    #
    def check(user_name: nil, api_token: nil, organization_id: nil, key: nil)
      @user_name = user_name || ENV["DANGER_FAVRO_USER_NAME"]
      @api_token = api_token || ENV["DANGER_FAVRO_API_TOKEN"]
      @organization_id = organization_id || ENV["DANGER_FAVRO_ORGANIZATION_ID"]
      @key = key || ENV["DANGER_FAVRO_KEY"]
      @issue_pattern = /(?<ticket>(#{@key})-(\d+))+/i

      fail("Danger Favro plugin: Missing `user_name`") && return if @user_name.nil? || @user_name.empty?
      fail("Danger Favro plugin: Missing `api_token`") && return if @api_token.nil? || @api_token.empty?
      fail("Danger Favro plugin: Missing `organization_id`") && return if @organization_id.nil? || @organization_id.empty?
      fail("Danger Favro plugin: Missing `key`") && return if @key.nil? || @key.empty?

      ids = find_ticket_ids([title] + file_additions)

      return if ids.empty?

      message "#{ids.length} Favro ticket#{ids.length > 1 ? 's' : ''} referenced"

      client = ApiClient.new(@user_name, @api_token, @organization_id)
      tickets = client.get(ids)

      render_table(tickets)
    end

    private

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
      table = "### Favro tickets \n"
      table << "ID | Name |\n"
      table << "| --- | ----- |\n"
      table << tickets.map { |ticket| render_row(ticket) }.join("\n")
      markdown table
    end

    def render_row(ticket)
      "[#{ticket.id}](https://favro.com/card/#{@organization_id}/#{ticket.id}) | #{ticket.name}"
    end
  end
end
