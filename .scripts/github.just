accept_header := "Accept: application/vnd.github+json"
github_api_ver_header := "X-GitHub-Api-Version: 2022-11-28"
root := `git rev-parse --show-toplevel`

github-init repo: (secrets repo) (deploy-key repo) (protect-branches repo) (ruleset repo) (dependabot repo) (webhook repo) (vulnerability-alerts repo) (custom-properties repo)

get-latest-tag repo:
    gh api "repos/{{ repo }}/tags" \
        --method GET \
        -H "{{ accept_header }}" \
        -H "{{ github_api_ver_header }}" \
        --jq '.[0].name'

bump-pre-commit-version:
    #!/usr/bin/env bash
    set -euo pipefail
    config="{{ root }}/.pre-commit-config.yaml"

    # Print table header
    printf "%-45s %-15s %-15s %s\n" "REPO" "CURRENT" "LATEST" "STATUS"
    printf "%-45s %-15s %-15s %s\n" "----" "-------" "------" "------"

    count=$(yq '.repos | length' "$config")

    for ((i=0; i<count; i++)); do
        repo_url=$(yq ".repos[$i].repo" "$config")
        rev=$(yq ".repos[$i].rev" "$config")

        # Extract owner/repo from GitHub URL
        gh_repo=$(echo "$repo_url" | sed -E 's|https://github.com/||')

        # Skip repos pinned to "main" or other branch names
        if [[ "$rev" == "main" || ! "$rev" =~ ^v?[0-9] ]]; then
            printf "%-45s %-15s %-15s %s\n" "$gh_repo" "$rev" "-" "⏭️"
            continue
        fi

        # Get latest tag from GitHub API
        latest=$(just get-latest-tag "$gh_repo" 2>/dev/null || echo "")

        if [[ -z "$latest" ]]; then
            printf "%-45s %-15s %-15s %s\n" "$gh_repo" "$rev" "?" "🆘"
            continue
        fi

        if [[ "$rev" != "$latest" ]]; then
            yq -i "(.repos[] | select(.repo == \"$repo_url\")).rev = \"$latest\"" "$config"
            printf "%-45s %-15s %-15s %s\n" "$gh_repo" "$rev" "$latest" "🚀"
        else
            printf "%-45s %-15s %-15s %s\n" "$gh_repo" "$rev" "$latest" "😎"
        fi
    done

protect-branches repo: (branch-protection repo "main")

branch-protection repo branch:
    gh api "repos/{{ repo }}/branches/{{ branch }}/protection" \
        --method PUT \
        -H "{{ accept_header }}" \
        -H "{{ github_api_ver_header }}" \
        --input - <<< $(jq -r '.' "{{ root }}/.github/rulesets/branch-protection.json")
    gh api \
        --method POST \
        -H "{{ accept_header }}" \
        -H "{{ github_api_ver_header }}" \
        "/repos/{{ repo }}/branches/{{ branch }}/protection/enforce_admins"
    gh api \
        --method PATCH \
        -H "{{ accept_header }}" \
        -H "{{ github_api_ver_header }}" \
        "/repos/{{ repo }}/branches/{{ branch }}/protection/required_pull_request_reviews" \
        --input - <<< $(jq -r '.' "{{ root }}/.github/rulesets/pr-reviews.json")
    gh api \
      --method POST \
      -H "{{ accept_header }}" \
      -H "{{ github_api_ver_header }}" \
      "/repos/{{ repo }}/branches/{{ branch }}/protection/required_signatures"
    gh api \
        --method PATCH \
        -H "{{ accept_header }}" \
        -H "{{ github_api_ver_header }}" \
        "/repos/{{ repo }}/branches/{{ branch }}/protection/required_status_checks" \
        --input - <<< $(jq -r '.' "{{ root }}/.github/rulesets/required-status-checks.json")
    gh api \
        --method PUT \
        -H "{{ accept_header }}" \
        -H "{{ github_api_ver_header }}" \
        "/repos/{{ repo }}/branches/{{ branch }}/protection/restrictions/apps" \
        --input - <<< $(jq -r '.' "{{ root }}/.github/rulesets/app-restrictions.json")
    gh api \
        --method PUT \
        -H "{{ accept_header }}" \
        -H "{{ github_api_ver_header }}" \
        "/repos/{{ repo }}/branches/{{ branch }}/protection/restrictions/users" \
        --input - <<< $(jq -r '.' "{{ root }}/.github/rulesets/user-restrictions.json")

ruleset repo:
    gh api \
      --method POST \
      -H "{{ accept_header }}" \
      -H "{{ github_api_ver_header }}" \
      "/repos/{{ repo }}/rulesets" \
      --input - <<< $(jq -r '.' "{{ root }}/.github/rulesets/ruleset.json")

dependabot repo:
    gh api \
        --method PATCH \
        -H "{{ accept_header }}" \
        -H "{{ github_api_ver_header }}" \
        "/repos/{{ repo }}/dependabot/alerts/ALERT_NUMBER" \
        -f 'state=dismissed' \
        -f 'dismissed_reason=tolerable_risk' \
        -f 'dismissed_comment=This alert is accurate but we use a sanitizer.'
    gh api \
        --method PUT \
        -H "{{ accept_header }}" \
        -H "{{ github_api_ver_header }}" \
        "/repos/{{ repo }}/automated-security-fixes"
    gh api \
        --method PUT \
        -H "{{ accept_header }}" \
        -H "{{ github_api_ver_header }}" \
        "/repos/{{ repo }}/dependabot/secrets/CHANGEME" \
        -f 'encrypted_value=c2VjcmV0' \
        -f 'key_id=012345678912345678'

webhook repo:
    gh api \
        --method POST \
        -H "{{ accept_header }}" \
        -H "{{ github_api_ver_header }}" \
        "/repos/{{ repo }}/hooks" \
        --input - <<< $(jq -r '.' "{{ root }}/.github/rulesets/webhook.json")

webhook-test repo id:
    gh api \
        --method POST \
        -H "{{ accept_header }}" \
        -H "{{ github_api_ver_header }}" \
        "/repos/{{ repo }}/hooks/{{ id }}/tests"

attestation repo:
    gh api \
        --method POST \
        -H "{{ accept_header }}" \
        -H "{{ github_api_ver_header }}" \
        "/repos/{{ repo }}/attestations" \
        --input - <<< $(jq -r '.' "{{ root }}/.github/rulesets/attestation.json")

immutable-release repo:
    gh api \
        --method PUT \
        -H "{{ accept_header }}" \
        -H "{{ github_api_ver_header }}" \
        "/repos/{{ repo }}/immutable-releases"

vulnerability-alerts repo:
    gh api \
        --method POST \
        -H "{{ accept_header }}" \
        -H "{{ github_api_ver_header }}" \
        "/repos/{{ repo }}/vulnerability-alerts"

custom-properties repo:
    gh api \
        --method PATCH \
        -H "{{ accept_header }}" \
        -H "{{ github_api_ver_header }}" \
        "/repos/{{ repo }}/properties/values" \
        --input - <<< $(jq -r '.' "{{ root }}/.github/rulesets/custom-properties.json")

labels repo: (clear-labels repo)
    gh api \
        --method POST \
        -H "{{ accept_header }}" \
        -H "{{ github_api_ver_header }}" \
        "/repos/{{ repo }}/labels" \
        -f 'name=bug' -f 'description=Something isn'\''t working' -f 'color=f29513'

clear-labels repo:
    #!/usr/bin/env bash
    labels=$(gh api -H "{{ accept_header }}" -H "{{ github_api_ver_header }}" "/repos/{{ repo }}/labels" | jq -r '.[].name')
    for label in $labels; do
        gh api \
            --method DELETE \
            -H "{{ accept_header }}" \
            -H "{{ github_api_ver_header }}" \
            "/repos/{{ repo }}/labels/$label"
    done

deploy-key repo:
    gh api \
        --method POST \
        -H "{{ accept_header }}" \
        -H "{{ github_api_ver_header }}" \
        "/repos/{{ repo }}/keys" \
        -f 'title=deploy-key' \
        -f "key=$(op read "op://gh-{{ replace("/", repo, "-") }}/deploy-key")" \
        -f 'read_only=true'

codeql repo:
    gh api \
        --method POST \
        -H "{{ accept_header }}" \
        -H "{{ github_api_ver_header }}" \
        "/repos/{{ repo }}/code-scanning/codeql/variant-analyses" \
        --input - <<< $(jq -r '.' "{{ root }}/.github/rulesets/codeql.json")
    gh api \
        --method POST \
        -H "{{ accept_header }}" \
        -H "{{ github_api_ver_header }}" \
        "/repos/{{ repo }}/code-scanning/alerts/ALERT_NUMBER/autofix"

checks repo:
    gh api \
      --method POST \
      -H "{{ accept_header }}" \
      -H "{{ github_api_ver_header }}" \
      "/repos/{{ repo }}/check-runs" \
       -f 'name=mighty_readme' \
       -f 'head_sha=ce587453ced02b1526dfb4cb910479d431683101' \
       -f 'status=in_progress' \
       -f 'external_id=42' \
       -f 'started_at=2018-05-04T01:14:52Z' \
       -f 'output[title]=Mighty Readme report' \
       -f 'output[summary]=' \
       -f 'output[text]='
    gh api \
        --method POST \
        -H "{{ accept_header }}" \
        -H "{{ github_api_ver_header }}" \
        "/repos/{{ repo }}/check-suites" \
        -f 'head_sha=d6fde92930d4715a2b49857d24b940956b26d2d3'

publish-codeql repo:
    gh api \
        --method POST \
        -H "{{ accept_header }}" \
        -H "{{ github_api_ver_header }}" \
        "/repos/{{ repo }}/code-scanning/sarifs" \
        -f 'commit_sha=4b6472266afd7b471e86085a6659e8c7f2b119da' \
        -f 'ref=refs/heads/master' \
        -f 'sarif=H4sICMLGdF4AA2V4YW1wbGUuc2FyaWYAvVjdbts2FL7PUxDCijaA/CM7iRNfLkPXYgHSNstumlzQ0pHFVCI1korjFgH2ONtr7Ul2KFmy/mOn6QIkjsjDw0/nfN85NL8dEGL9pNwAImqRObECrWM1H40kXQ2XTAfJIlEgXcE1cD10RTQSVDE10K4aKSqZP1AxuKOIKg1ydJU60jSfSh8Hk6EzHA/vlOCWbfa7B6kYPpj90rlsWCZcmbHP5Bs+4oAWIjQD2SMOeJLh2vIQDnIaQerqXHjw8YIgxohybxAyDsS4cAPKsp03K4RcUs6+Up2D+JXpd8mibKIQN9fM/aMCdbyBujGSSQgVxJtx5qX2d2qUcIweQhEuDQf3GBO6CKHkogx/N3MVCKl/AeVKFuf4y5ubsMGDTj1ep+5I7sgmLIpxtU38hLtmMRGSuCFVyip5eKzs5ydh+LztVL6f2m6oih1BkYiuyQIIJWodxVpERPj4sEiWBNNH8EWT0DMG8EAjzKVHXCrB4FkPu/F64NMk1OeC+2yZSNoBOoR7CC0EzYWGbm+xFDFIzbI011+cLjfZtyJkmMZfumAh02uL3NpV2y+MZ6RAjxibyKrNxxJcVjANSb4eBGwZ1M0KsuyR2poLr5rMl8vaDSeVn6eTWEO2j2xIEcmhwlTKNOi4GMOI8gfuZYkvJ7b4v5Tiumyz7RnHeodFzpS8ASIZCH/AYdWi2z3sG8JtFxJ6fF9yR9CdifBr9Pd6d5V2+zbJKjjCFGGmsHuYFy2ytJq9tUxcLSRSQecppOGKrpUxYfxefMEFK+wOGa4hudQByBVT0L+EKtyACxnRsABhEx1QjVDs1KNI9MbpnhqfE45B6FJvu3hRu5VRU9MhZLmK7fqkKyQSTHNoyMqUFMqXCV3CwAeqEwmVokraK8IuBaGvHjQ0gMYrKjnjyw7uk9uD8tgmsBbFMPnU1bV2ZhkJNkuolUiWys3UPWzs5aaIUz9TBe8zMb+6+nT+6fLy91dlE3xzeDDT4zYszb0bW6NjJd0Rvn2EnLvWLFSdKPpBzInzfRgu8ETyMcH8nIfMnJCeC2PyfTA+UKngcnGH7Hw2hGkVQs5YlIRCtdWZYQ4/73es2JlxkfViOEIhoWJq5Oo6UBBfiKIqFBWhiE3jJGbFwVoxBHTRSuIS67sMeplei24X20shLjG+8gqbKC/bESiNMC+wd5q5id0yeS7CJEqXzmrTWNq3k05l84P6f4/bEmXFJjI0fIt1BGQssUnUDkBYeVhE5TqPnMH3jqogDcP0zKcTgLPTMSzOjhbjuVOmW23l1fYNStulfo6sXlFsGLhbDy5RECPRYGCTgOj2bd4nUQEivEd0H7KKYxqnEhFohuur3a3UPskbH/+Yg0+M5P2MHRJu3ziHh3Z2NCrWt3XF1rWTw8Ne/pfbWYXnDSE0SNZQQt1i18q7te2vOhu7ehWuvVyeu0wbLZi24mhoo6aOOTltzG/lgdVvVoXQq5V+pewkFIzL8fjEcadT55jOjpzFzHuOTtDNrMkJPMVQDd7F09RID72O/UPZ0tmctqZ7kWX6EmSZnDpP8GU67SXM8XE3YSrxbKsx6UReZ4y6n/FVZfJjs9Z7stma75W5yQtkzjk5eSJxk1lv4o7+j8TlhaJ2lsKWZO6lruDPBLib3x5ZN/KGWzZ+pn///evv7OOf4iIBv3oY9L/l1wiJ9p0Tc+F1zZnOE9NxXWEus6IQhr5pMfoqxi8WPsuu0azsns4UC6WzNzHIzbeEx4P/AJ3SefgcFAAA'

secrets repo:
    gh api \
        --method PUT \
        -H "{{ accept_header }}" \
        -H "{{ github_api_ver_header }}" \
        "/repos/{{ repo }}/actions/secrets/CHANGEME" \
        -f 'encrypted_value=c2VjcmV0' -f 'key_id=012345678912345678'
    gh api \
        --method PUT \
        -H "{{ accept_header }}" \
        -H "{{ github_api_ver_header }}" \
        "/repos/{{ repo }}/environments/ENVIRONMENT_NAME/secrets/SECRET_NAME" \
        -f 'encrypted_value=c2VjcmV0' -f 'key_id=012345678912345678'
