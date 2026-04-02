require 'fastlane/action'
require_relative '../helper/depot_helper'
require 'faraday'
require 'faraday/multipart'
require 'json'

module Fastlane
  module Actions
    class DepotAction < Action
      def self.run(params)
        localpath = Actions.lane_context[Fastlane::Actions::SharedValues::IPA_OUTPUT_PATH] || Actions.lane_context[Fastlane::Actions::SharedValues::GRADLE_APK_OUTPUT_PATH]
        if localpath.nil?
          UI.user_error!("IPA 或 APK 文件路径不存在")
        end

        token = params[:token]
        url = "#{params[:url]}/upload"

        UI.message("正在上传文件到 #{url} ...")

        conn = Faraday.new(url: url) do |f|
          f.request :multipart
          f.request :url_encoded
          f.adapter Faraday.default_adapter
        end

        payload = {
          app_file: Faraday::Multipart::FilePart.new(localpath, 'application/octet-stream')
        }

        response = conn.post do |req|
          req.headers['Accept'] = 'application/json'
          req.headers['X-Auth-Token'] = token.to_s
          req.body = payload
        end

        if response.success?
          UI.success("上传完成: #{response.body}")
          answer = JSON.parse(response.body)
          return answer
        else
          UI.user_error!("上传失败: #{response.status} #{response.body}")
        end
        return response.body
      end

      def self.description
        "Upload ipa to sdas service"
      end

      def self.authors
        ["Ekko"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        # Optional:
        "Upload ipa to sdas service"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :token,
                                       description: "认证 Token",
                                       optional: true),
          FastlaneCore::ConfigItem.new(key: :url,
                                       description: "API 地址",
                                       optional: true)
        ]
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://docs.fastlane.tools/advanced/#control-configuration-by-lane-and-by-platform
        #
        # [:ios, :mac, :android].include?(platform)
        true
      end
    end
  end
end
