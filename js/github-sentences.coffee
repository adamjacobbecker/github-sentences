repo_link = (name) ->
  """<a href="http://github.com/#{name}" target="_blank">#{name}</a>"""

user_link = (username) ->
  """<a href="http://github.com/user/#{username}" target="_blank">#{username}</a>"""

github_event_types =
  "CommitCommentEvent":
    name: "Commit Comment"
  "CreateEvent":
    name: "Repo or Branch Created"
    render: (event) ->
      if event.payload.ref_type is "repository"
        """ #{user_link(event.actor.login)} created #{event.payload.ref_type} #{repo_link(event.repo.name)} """
      else
        """ #{user_link(event.actor.login)} created #{event.payload.ref_type} "#{event.payload.ref}" on #{repo_link(event.repo.name)} """

  "DeleteEvent":
    name: "Branch/Tag Deleted"
    render: (event) ->
      """ #{user_link(event.actor.login)} deleted #{event.payload.ref_type} "#{event.payload.ref}" on #{repo_link(event.repo.name)} """

  "DownloadEvent":
    name: "Download"
  "FollowEvent":
    name: "User Followed"
  "ForkEvent":
    name: "Fork"
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
      """ #{user_link(event.actor.login)} pushed to #{repo_link(event.repo.name)} """

  "TeamAddEvent":
    name: "Team Added"
  "WatchEvent":
    name: "Repo Watched"
    render: (event) ->
      """ #{user_link(event.actor.login)} #{event.payload.action} watching #{repo_link(event.repo.name)} """


window.githubSentences =
  convert: (event) ->
    if github_event_types[event.type]["render"]?
      github_event_types[event.type]["render"](event)
    else
      event.type
