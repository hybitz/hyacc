module MyGitStrategy
  def test
    test! " [ -f #{repo_path}/HEAD ] "
  end

  def check
    test! :git, :'ls-remote -h', repo_url
  end

  def clone
    git :clone, '--mirror', repo_url, repo_path
  end

  def update
    git :remote, :update
  end

  def release
    git :clone, '-b', fetch(:branch), '.', release_path
  end

  def fetch_revision
    context.capture(:git, "rev-parse --short #{fetch(:branch)}")
  end
end
