# git-cliff ~ configuration file
# https://git-cliff.org/docs/configuration
#
# Lines starting with "#" are comments.
# Configuration options are organized into tables and keys.
# See documentation for more information on available options.

[changelog]
# changelog header
header = """"""
body = """
{%- macro remote_url() -%}
  https://github.com/{{ "{{" }} remote.github.owner {{ "}}" }}/{{ "{{" }} remote.github.repo {{ "}}" }}
{%- endmacro -%}

{% macro print_commit(commit) -%}
    - {% if commit.scope %}*({{ "{{" }} commit.scope }})* {% endif %}\
        {% if commit.breaking %}[**breaking**] {% endif %}\
        {{ "{{" }} commit.message | upper_first }} - \
        ([{{ "{{" }} commit.id | truncate(length=7, end="") {{ "}}" }}]({{ "{{" }} self::remote_url() {{ "}}" }}/commit/{{ "{{" }} commit.id {{ "}}" }}))\
{% endmacro -%}

{% if version %}\
    {% if previous.version %}\
        ## [{{ "{{" }} version | trim_start_matches(pat="v") {{ "}}" }}]\
          ({{ "{{" }} self::remote_url() {{ "}}" }}/compare/{{ "{{" }} previous.version {{ "}}" }}..{{ "{{" }} version {{ "}}" }}) - {{ "{{" }} timestamp | date(format="%Y-%m-%d") {{ "}}" }}
    {% else %}\
        ## [{{ "{{" }} version | trim_start_matches(pat="v") {{ "}}" }}] - {{ "{{" }} timestamp | date(format="%Y-%m-%d") {{ "}}" }}
    {% endif %}\
{% else %}\
    <!-- markdownlint-disable first-line-heading -->
    ## [unreleased]
{% endif %}\

{% for group, commits in commits | group_by(attribute="group") %}
    ### {{ "{{" }} group | striptags | trim | upper_first {{ "}}" }}
    {% for commit in commits
    | filter(attribute="scope")
    | sort(attribute="scope") %}
        {{ "{{" }} self::print_commit(commit=commit) {{ "}}" }}
    {%- endfor -%}
    {% raw %}\n{% endraw %}\
    {%- for commit in commits %}
        {%- if not commit.scope -%}
            {{ "{{" }} self::print_commit(commit=commit) {{ "}}" }}\
            {% if commit.github.username %} by @{{ "{{" }} commit.github.username {{ "}}" }}{%- endif -%}\
            {% raw %}\n{% endraw -%}
        {% endif -%}
    {% endfor -%}
{% endfor %}\n

{%- if github -%}
{% if github.contributors | filter(attribute="is_first_time", value=true) | length != 0 %}
  ## New Contributors{% raw %}\n{% endraw -%}
{%- endif %}\
{% for contributor in github.contributors | filter(attribute="is_first_time", value=true) %}
  - @{{ "{{" }} contributor.username {{ "}}" }} made their first contribution
    {%- if contributor.pr_number %} in \
      [#{{ "{{" }} contributor.pr_number {{ "}}" }}]({{ "{{" }} self::remote_url() {{ "}}" }}/pull/{{ "{{" }} contributor.pr_number {{ "}}" }}) \
    {%- endif %}
{%- endfor -%}
{%- endif -%}
""" # template for the changelog body
# https://keats.github.io/tera/docs/#introduction
# template for the changelog footer
footer = """"""
# remove the leading and trailing whitespace from the templates
trim = true
# postprocessors
postprocessors = [
  { pattern = '<REPO>', replace = "https://github.com/{{ stencil.Arg "org" }}/{{ .Config.Name }}" }, # replace repository URL
]

[git]
# parse the commits based on https://www.conventionalcommits.org
conventional_commits = true
# filter out the commits that are not conventional
filter_unconventional = true
# process each line of a commit as an individual commit
split_commits = false
# regex for preprocessing the commit messages
commit_preprocessors = [
  { pattern = '\((\w+\s)?#([0-9]+)\)', replace = "([#${2}](<REPO>/issues/${2}))" },
]
# regex for parsing and grouping commits
commit_parsers = [
  { message = "^feat", group = "<!-- 0 -->⛰️  Features" },
  { message = "^fix", group = "<!-- 1 -->🐛 Bug Fixes" },
  { message = "^doc", group = "<!-- 3 -->📚 Documentation" },
  { message = "^perf", group = "<!-- 4 -->⚡ Performance" },
  { message = "^refactor", group = "<!-- 2 -->🚜 Refactor" },
  { message = "^style", group = "<!-- 5 -->🎨 Styling" },
  { message = "^test", group = "<!-- 6 -->🧪 Testing" },
  { message = "^chore\\(release\\): prepare for", skip = true },
  { message = "^chore\\(go\\)", skip = true },
  { message = "^chore|^ci|^build", group = "<!-- 7 -->⚙️ Miscellaneous Tasks" },
  { body = ".*security", group = "<!-- 8 -->🛡️ Security" },
  { message = "^revert", group = "<!-- 9 -->◀️ Revert" },
]
# protect breaking changes from being skipped due to matching a skipping commit_parser
protect_breaking_commits = false
# filter out the commits that are not matched by commit parsers
filter_commits = false
# regex for matching git tags
tag_pattern = "v[0-9].*"
# regex for ignoring tags
ignore_tags = "rc"
# sort the tags topologically
topo_order = false
# sort the commits inside sections by oldest/newest order
sort_commits = "newest"
