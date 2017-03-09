#!/usr/bin/env ruby

require 'json'
require_relative 'base'
require_relative '../repository'

module Commands
  class Check < Commands::Base
    def output
      out = []
      version = input.version

      repo.pull_requests.each do |pull_request|
        out << pull_request.as_json

        # Append versions for build request comments
        pull_request.trigger_comment_ids.each do |comment_id|
          payload = pull_request.as_json
          payload[:comment] = comment_id.to_s
          out << payload
        end
      end

      return out
    end

    private

    def repo
      @repo ||= Repository.new(name: input.source.repo)
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  command = Commands::Check.new
  puts JSON.generate(command.output)
end
