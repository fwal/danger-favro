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

      it "should throw errors when missing user_name" do
        @my_plugin.check
        expect(@dangerfile.status_report[:errors]).to eq(["Danger Favro plugin: Missing `user_name`"])
      end

      it "should throw errors when missing api_token" do
        @my_plugin.check(user_name: "test")
        expect(@dangerfile.status_report[:errors]).to eq(["Danger Favro plugin: Missing `api_token`"])
      end

      it "should throw errors when missing organization_id" do
        @my_plugin.check(user_name: "test", api_token: "test")
        expect(@dangerfile.status_report[:errors]).to eq(["Danger Favro plugin: Missing `organization_id`"])
      end

      it "should throw errors when missing key" do
        @my_plugin.check(user_name: "test", api_token: "test", organization_id: "test")
        expect(@dangerfile.status_report[:errors]).to eq(["Danger Favro plugin: Missing `key`"])
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

      it "detects tickets in added lines" do
        testing_changes(@dangerfile, added_text: "//TEST-123")
        testing_api_request("TEST-123")

        @my_plugin.check
        expect(@dangerfile.status_report[:messages]).to eq(["1 Favro ticket referenced"])
      end

      it "doesn't detect tickets in removed lines" do
        testing_changes(@dangerfile, modified_text: "//TEST-1234")

        @my_plugin.check
        expect(@dangerfile.status_report[:messages]).to eq([])
      end

      it "retrieves the name of detected tickets" do
        testing_changes(@dangerfile, added_text: "//TEST-123")
        testing_api_request("TEST-123")

        @my_plugin.check
        expect(@dangerfile.status_report[:markdowns][0].message).to eq("### Favro tickets \nID | Name |\n| --- | ----- |\n[TEST-123](https://favro.com/card/test_org/TEST-123) | This is a card")
      end

      context "on GitHub PR" do
        it "detects Favro ticket in PR title" do
          testing_pr_title(@dangerfile, "TEST-123")
          testing_api_request("TEST-123")

          @my_plugin.check
          expect(@dangerfile.status_report[:messages]).to eq(["1 Favro ticket referenced"])
        end
      end
    end
  end
end
