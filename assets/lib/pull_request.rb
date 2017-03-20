require 'octokit'

class PullRequest
  def self.from_github(repo:, id:, input: Input.instance)
    pr = Octokit.pull_request(repo.name, id)
    PullRequest.new(pr: pr, input: input)
  end

  def initialize(pr:, input: Input.instance)
    @pr = pr
    @input = input
  end

  def from_fork?
    base_repo != head_repo
  end

  def equals?(id:, sha:)
    [self.sha, self.id.to_s] == [sha, id.to_s]
  end

  def to_json(*)
    as_json.to_json
  end

  def as_json
    { 'ref' => sha, 'pr' => id.to_s }
  end

  def id
    @pr['number']
  end

  def sha
    @pr['head']['sha']
  end

  def trigger_comment_ids
    comment_ids = []

    comments.each do |comment|
      if @input.source.trigger_message.match(comment[:body])
        comment_ids << comment[:id]
      elsif /(concourse,? )?(re-?)?(test|build) this,? please(,? concourse)?/i.match(comment[:body])
        comment_ids << comment[:id]
      end
    end

    return comment_ids
  end

  def url
    @pr['html_url']
  end

  private

  def base_repo
    @pr['base']['repo']['full_name']
  end

  def head_repo
    @pr['head']['repo']['full_name']
  end

  def comments
    Octokit::issue_comments head_repo, id
  end

end
