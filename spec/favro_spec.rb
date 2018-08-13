require File.expand_path("../spec_helper", __FILE__)

module Danger
  describe Danger::DangerFavro do
    it "should be a plugin" do
      expect(Danger::DangerFavro.new(nil)).to be_a Danger::Plugin
    end

    describe "with Dangerfile without configuration" do
      before do
        @dangerfile = testing_dangerfile
        @my_plugin = @dangerfile.favro
      end

      it "should throw errors when missing values" do
        @my_plugin.check
        errors = [
          "Danger Favro plugin: Missing `user_name`",
          "Danger Favro plugin: Missing `api_token`",
          "Danger Favro plugin: Missing `organization_id`",
          "Danger Favro plugin: Missing `key`"
        ]
        expect(@dangerfile.status_report[:errors]).to eq(errors)
      end
    end

    describe "with Dangerfile" do
      before do
        @dangerfile = testing_dangerfile
        @my_plugin = @dangerfile.favro

        ENV["DANGER_FAVRO_USER_NAME"] = "test_user"
        ENV["DANGER_FAVRO_API_TOKEN"] = "test_token"
        ENV["DANGER_FAVRO_ORGANIZATION_ID"] = "test_org"
        ENV["DANGER_FAVRO_KEY"] = "test"

        testing_pr_title(@dangerfile)
        testing_changes(@dangerfile)
      end

      it "should not throw errors if configured" do
        @my_plugin.check
        expect(@dangerfile.status_report[:errors]).to eq([])
      end

      it "detects cards in added lines" do
        testing_changes(@dangerfile, added_text: "//TEST-123")
        testing_api_request("TEST-123")

        @my_plugin.check
        expect(@dangerfile.status_report[:markdowns][0].message.delete("\n")).to eq(comment_table)
      end

      it "doesn't detect cards in removed lines" do
        testing_changes(@dangerfile, modified_text: "//TEST-1234")

        @my_plugin.check
        expect(@dangerfile.status_report[:markdowns]).to eq([])
      end

      it "retrieves the name of detected cards" do
        testing_changes(@dangerfile, added_text: "//TEST-123")
        testing_api_request("TEST-123")

        @my_plugin.check
        expect(@dangerfile.status_report[:markdowns][0].message.delete("\n")).to eq(comment_table)
      end

      it "doesn't report duplicate favro cards" do
        testing_pr_title(@dangerfile, "test-123")
        testing_changes(@dangerfile, added_text: "//TEST-123")
        testing_changes(@dangerfile, added_text: "//TesT-123")
        testing_api_request("TEST-123")

        @my_plugin.check
        expect(@dangerfile.status_report[:markdowns][0].message.delete("\n")).to eq(comment_table)
      end

      context "on GitHub PR" do
        it "detects Favro card in PR title" do
          testing_pr_title(@dangerfile, "TEST-123")
          testing_api_request("TEST-123")

          @my_plugin.check
          expect(@dangerfile.status_report[:markdowns][0].message.delete("\n")).to eq(comment_table)
        end
      end
    end
  end
end
