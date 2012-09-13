repo_link = (name) ->
  """<a href="http://github.com/#{name}" target="_blank">#{name}</a>"""

user_link = (username) ->
  """<a href="http://github.com/user/#{username}" target="_blank">#{username}</a>"""

strip_hash = (link) ->
  link.replace(/\#.*$/, '')

link_to = (url, name) ->
  """<a href="#{url}" target="_blank">#{name || url}</a>"""

github_event_types =
  "CommitCommentEvent":
    name: "Commit Comment"
    render: (event) ->
      sentence: """ #{user_link(event.actor.login)} commented on a commit in
                    #{link_to(strip_hash(event.payload.comment.html_url), event.repo.name)} """

  "CreateEvent":
    name: "Repo or Branch Created"
    render: (event) ->
      if event.payload.ref_type is "repository"
        sentence: """ #{user_link(event.actor.login)} created #{event.payload.ref_type} #{repo_link(event.repo.name)} """
      else
        sentence: """ #{user_link(event.actor.login)} created #{event.payload.ref_type} "#{event.payload.ref}" on #{repo_link(event.repo.name)} """

  "DeleteEvent":
    name: "Branch/Tag Deleted"
    render: (event) ->
      sentence: """ #{user_link(event.actor.login)} deleted #{event.payload.ref_type} "#{event.payload.ref}" on #{repo_link(event.repo.name)} """

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
  "IssueCommentEvent":
    name: "Issue Comment"
  "IssuesEvent":
    name: "Issue Opened/CLosed"
  "MemberEvent":
    name: "Collaborator Added"
  "PublicEvent":
    name: "Repo Open-Sourced"
  "PullRequestEvent":
    name: "Pull Request Opened/CLosed"
  "PullRequestReviewCommentEvent":
    name:  "Pull Request Comment"
  "PushEvent":
    name: "Push"
    render: (event) ->
      # todo: make this link to the correct commit
      sentence: """ #{user_link(event.actor.login)} pushed to #{repo_link(event.repo.name)} """

  "TeamAddEvent":
    name: "Team Added"
  "WatchEvent":
    name: "Repo Watched"
    render: (event) ->
      sentence: """ #{user_link(event.actor.login)} #{event.payload.action} watching #{repo_link(event.repo.name)} """


window.githubSentences =
  convert: (event) ->
    if github_event_types[event.type]["render"]?
      converted = github_event_types[event.type]["render"](event)
    else
      converted =
        sentence: event.type

    html = """
      <div class="github-item">
        <div class="sentence">#{converted.sentence}</div>
        <div class="timestamp">#{event.created_at}</div>
    """

    if converted.details?
      html += """ <div class="details">#{converted.details}</div> """

    html += """
      </div>
    """
