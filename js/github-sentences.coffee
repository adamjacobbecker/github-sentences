repo_link = (name) ->
  """<a href="http://github.com/#{name}" target="_blank">#{name}</a>"""

user_link = (username) ->
  """<a href="http://github.com/#{username}" target="_blank">#{username}</a>"""

commit_link = (commit, repo_name) ->
  return if !commit? or !repo_name?
  """<a href="http://github.com/#{repo_name}/commit/#{commit.sha}" target="_blank">#{commit.message}</a>"""

strip_hash = (link) ->
  link.replace(/\#.*$/, '')

link_to = (url, name) ->
  """<a href="#{url}" target="_blank">#{name || url}</a>"""

github_event_types =
  "CommitCommentEvent":
    name: "Commit Comment"
    render: (event) ->
      sentence: """ #{user_link(event.actor.login)} commented on #{link_to(event.payload.comment.html_url, 'a commit')} in
                    #{repo_link(event.repo.name)} """

  "CreateEvent":
    name: "Repo or Branch Created"
    render: (event) ->
      if event.payload.ref_type is "repository"
        sentence: """ #{user_link(event.actor.login)} created #{event.payload.ref_type} #{repo_link(event.repo.name)} """
      else
        sentence: """ #{user_link(event.actor.login)} created #{event.payload.ref_type} "#{event.payload.ref}" in #{repo_link(event.repo.name)} """

  "DeleteEvent":
    name: "Branch/Tag Deleted"
    render: (event) ->
      sentence: """ #{user_link(event.actor.login)} deleted #{event.payload.ref_type} "#{event.payload.ref}" in #{repo_link(event.repo.name)} """

  "DownloadEvent":
    name: "Download"
    render: (event) ->
      sentence: """ #{user_link(event.actor.login)} uploaded #{link_to(event.payload.download.html_url, event.payload.download.name)}
                to #{repo_link(event.repo.name)} """
  "FollowEvent":
    name: "User Followed"
  "ForkEvent":
    name: "Fork"
    render: (event) ->
      sentence: """ #{user_link(event.actor.login)} forked #{repo_link(event.repo.name)}
                to #{repo_link(event.payload.forkee.full_name)} """

  "ForkApplyEvent":
    name: "Fork Applied"
  "GistEvent":
    name: "Gist Created/Updated"
  "GollumEvent":
    name: "Wiki Updated"
    render: (event) ->
      sentence: """ #{user_link(event.actor.login)} #{event.payload.pages.action} #{link_to(event.payload.pages.html_url, event.payload.pages.title)}
        in the #{repo_link(event.repo.name)} wiki
      """

  "IssueCommentEvent":
    name: "Issue Comment"
    render: (event) ->
      actionText = switch event.payload.action
        when "created" then "commented on"
        else event.payload.action

      sentence: """
        #{user_link(event.actor.login)} #{actionText} #{link_to(event.payload.issue.html_url, 'Issue #' + event.payload.issue.number)} in
        #{repo_link(event.repo.name)}
      """

  "IssuesEvent":
    name: "Issue Opened/CLosed"
    render: (event) ->
      sentence: """
          #{user_link(event.actor.login)} #{event.payload.action} #{link_to(event.payload.issue.html_url, 'Issue #' + event.payload.issue.number)} in
          #{repo_link(event.repo.name)}
        """
  "MemberEvent":
    name: "Collaborator Added"
  "PublicEvent":
    name: "Repo Open-Sourced"
    render: (event) ->
      sentence: """
          #{user_link(event.actor.login)} open-sourced #{repo_link(event.repo.name)}
      """

  "PullRequestEvent":
    name: "Pull Request Opened/CLosed"
    render: (event) ->
      # todo: make this link to the correct commit
      sentence: """ #{user_link(event.actor.login)} #{event.payload.action}
                    #{link_to(event.payload.pull_request.html_url, 'Pull Request #' + event.payload.pull_request.number)} in
        #{repo_link(event.repo.name)}
      """

  "PullRequestReviewCommentEvent":
    name:  "Pull Request Comment"
  "PushEvent":
    name: "Push"
    render: (event) ->
      commit = if (event.payload.commits instanceof Array) then event.payload.commits[0] else event.payload.commits
      sentence: """ #{user_link(event.actor.login)} pushed "#{commit_link(commit, event.repo.name)}" to #{repo_link(event.repo.name)} """

  "TeamAddEvent":
    name: "Team Added"
  "WatchEvent":
    name: "Repo Watched"
    render: (event) ->
      sentence: """ #{user_link(event.actor.login)} #{event.payload.action} watching #{repo_link(event.repo.name)} """


window.githubSentences =
  eventTypes: github_event_types
  convert: (event) ->
    if github_event_types[event.type]["render"]?
      converted = github_event_types[event.type]["render"](event)
    else
      converted =
        sentence: event.type

    html = """
      <div class="github-sentence-item event-#{event.type.toLowerCase()}">
        <div class="avatar"><img src="#{event.actor.avatar_url}" /></div>
        <div class="sentence">#{converted.sentence}</div>
        <div class="timestamp">#{event.created_at}</div>
    """

    if converted.details?
      html += """ <div class="details">#{converted.details}</div> """

    html += """
      </div>
    """
