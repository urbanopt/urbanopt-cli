# *******************************************************************************
# OpenStudio(R), Copyright (c) 2008-2020, Alliance for Sustainable Energy, LLC.
# All rights reserved.
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# (1) Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
#
# (2) Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#
# (3) Neither the name of the copyright holder nor the names of any contributors
# may be used to endorse or promote products derived from this software without
# specific prior written permission from the respective party.
#
# (4) Other than as required in clauses (1) and (2), distributions in any form
# of modifications or other derivative works may not use the "OpenStudio"
# trademark, "OS", "os", or any other confusingly similar designation without
# specific prior written permission from Alliance for Sustainable Energy, LLC.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDER(S) AND ANY CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER(S), ANY CONTRIBUTORS, THE
# UNITED STATES GOVERNMENT, OR THE UNITED STATES DEPARTMENT OF ENERGY, NOR ANY OF
# THEIR EMPLOYEES, BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
# OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
# STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
# OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
# *******************************************************************************

require 'octokit'

class ChangeLog
  def initialize(user_and_repo, start_date = Date.today - 90, end_date = Date.today, apikey = nil)
    @user_and_repo = user_and_repo
    @apikey = apikey
    @start_date = start_date
    @end_date = end_date

    # Convert dates to time objects
    @start_date = Time.parse(@start_date.to_s) if start_date.is_a? String
    @end_date = Time.parse(@end_date.to_s) if end_date.is_a? String
    # GitHub API uses Time and not the Date class, so ensure that we have Time
    @start_date = Time.parse(@start_date.to_s)
    @end_date = Time.parse(@end_date.to_s)

    @total_open_issues = []
    @total_open_pull_requests = []
    @new_issues = []
    @closed_issues = []
    @accepted_pull_requests = []

    begin
      @github = Octokit::Client.new
      if apikey
        puts "Using Github token provided by user"
        @github = Octokit::Client.new(access_token: apikey)
      # elsif ENV['GITHUB_CHANGELOG_TOKEN']
      #   puts 'Using Github token from user environment'
      #   @github = Octokit::Client.new(access_token: ENV['GITHUB_CHANGELOG_TOKEN'])
      end
      @github.auto_paginate = true
    rescue StandardError => e
      puts e.message
      # write out the help message
      ChangeLog.help
      exit(1)
    end
  end

  # Class method to show how to use the API through Rake.
  def self.help
    puts 'Usage: bundle exec rake openstudio:change_log[<start_date>,<end_date>,<apikey>]'
    puts '       <start_date> = [Optional] Start of data (e.g., 2020-09-06), defaults to 90 days before today'
    puts '       <end_date> = [Optional] End of data (e.g., 2020-10-06), default to today'
    puts '       <apikey> = [Optional] GitHub API Key (used for private repos)'
    puts
    puts '  Ensure that the GitHub user/repo is set in your Rakefile, for example, '
    puts "    rake_task.set_extension_class(OpenStudio::Extension::Extension, 'nrel/openstudio-extension-gem')"
    puts
    puts '  Example usages:'
    puts '    bundle exec rake openstudio:change_log[2020-01-01]'
    puts '    bundle exec rake openstudio:change_log[2020-01-01,2020-06-30]'
    puts '    bundle exec rake openstudio:change_log[2020-01-01,2020-01-10,<private_api_key>]'
    puts
    puts '  Notes:'
    puts '    For creating token, see https://github.com/settings/tokens.'
    puts '    For security, set your token as an env variable. This script is prepared for one called GITHUB_CHANGELOG_TOKEN'
    puts '    Note that if passing apikey, then you must pass start_date and end_date as well. There must be no spaces'
    puts '    between the arguments (see examples above).'
  end

  # Process Open Issues
  def process
    @github.list_issues(@user_and_repo, state: 'all').each do |issue|
      if issue.state == 'open'
        if issue.pull_request
          if issue.created_at >= @start_date && issue.created_at <= @end_date
            @total_open_pull_requests << issue
          end
        else
          @total_open_issues << issue
          if issue.created_at >= @start_date && issue.created_at <= @end_date
            @new_issues << issue
          end
        end
      else
        # the issue is closed
        if issue.closed_at >= @start_date && issue.closed_at <= @end_date
          if issue.pull_request
            @accepted_pull_requests << issue
          else
            @closed_issues << issue
          end
        end
      end
    end

    @closed_issues.sort! { |x, y| x.number <=> y.number }
    @new_issues.sort! { |x, y| x.number <=> y.number }
    @accepted_pull_requests.sort! { |x, y| x.number <=> y.number }
    @total_open_pull_requests.sort! { |x, y| x.number <=> y.number }
  rescue StandardError => e
    puts e.message
    ChangeLog.help
    exit(1)
  end

  def print_issue(issue)
    is_feature = false
    issue.labels.each { |label| is_feature = true if label.name == 'Feature Request' }

    if is_feature
      "- Improved [##{issue.number}]( #{issue.html_url} ), #{issue.title}"
    else
      "- Fixed [\##{issue.number}]( #{issue.html_url} ), #{issue.title}"
    end
  end

  def print_issues
    puts "Total Open Issues: #{@total_open_issues.length}"
    puts "Total Open Pull Requests: #{@total_open_pull_requests.length}"
    puts "\nDate Range: #{@start_date.strftime('%m/%d/%y')} - #{@end_date.strftime('%m/%d/%y')}:"
    puts "\nNew Issues: #{@new_issues.length} (" + @new_issues.map(&:number).join(', ') + ')'

    puts "\nClosed Issues: #{@closed_issues.length}"
    @closed_issues.each { |issue| puts print_issue(issue) }

    puts "\nAccepted Pull Requests: #{@accepted_pull_requests.length}"
    @accepted_pull_requests.each { |issue| puts print_issue(issue) }

    puts "\nAll Open Issues: #{@total_open_issues.length} (" + @total_open_issues.map { |issue| "\##{issue.number}" }.join(', ') + ')'
  end
end
