import os
import logging
import subprocess
import sys
import gitlab
import urllib3

log_file_path = os.path.expanduser('~\\.config\\powershell\\gitlab_log.txt')
logging.basicConfig(
    filename=log_file_path,
    level=logging.ERROR,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

# Python gitlab docs: https://python-gitlab.readthedocs.io/en/stable/index.html
def create_mr(user_id, private_token, gitlab_url, http_remote, ssh_remote, title):
    urllib3.disable_warnings()

    gl = gitlab.Gitlab(gitlab_url, private_token=private_token, api_version=4, ssl_verify=False)

    result = subprocess.run(['git', 'branch', '--show-current'], capture_output=True, text=True)

    if result.returncode != 0:
        error_message = result.stderr.strip()
        print("Failed to get current branch. Likely not in a git repository. Check log for more info.")
        logging.error(f"Get branch locally failed. Error: {error_message}. Permission denied can mean .git not found")
        return

    branch_name = result.stdout.strip()

    if not title:
        title = subprocess.run(['git', 'log', '-1', '--pretty=%B'], capture_output=True, text=True).stdout.strip()

    subprocess.run(['git', 'push', '--quiet', '--set-upstream', 'origin', branch_name])

    project_url = subprocess.run(['git', 'remote', 'get-url', 'origin'], capture_output=True, text=True).stdout.strip()

    project_join = ""
    if project_url.startswith(http_remote):
        project_split = project_url.split("/")
        project_join = "/".join(project_split[3:])
    elif project_url.startswith(ssh_remote):
        project_split = project_url.split(":")
        project_join = ":".join(project_split[1:])
    else:
        print(f"Project did not start with http:// or git@, set remote URL with: git remote set-url origin <url>")
        logging.error(f"Project did not start with http:// or git@, set remote URL with: git remote set-url origin <url>")
        return

    if project_join.endswith(".git"):
        project_path = project_join[:-4]
    else:
        print(f"Project did not end in .git, set remote URL with: git remote set-url origin <url>")
        logging.error(f"Project did not end in .git, set remote URL with: git remote set-url origin <url>")
        return

    print("Project: " + project_path)

    try:
        project = gl.projects.get(project_path)
        project_id = project.id
        target_branch = project.default_branch
    except gitlab.exceptions.GitlabGetError as e:
        print(f"Error fetching group. Check log for more info.")
        logging.error(f"Error fetching group for project path: {project_path}. Error: {e}")
        return
 
    issue_body = {
        "assignee_ids": [user_id],
        "title": title
    }

    try:
        issue = project.issues.create(issue_body)
        mr_description = f"""### Reviewer Checklist

- [ ] The change includes tests
- [ ] The change is free from noisy whitespace/formatting changes

### Changing any handles? - No

- [ ] What handles are affected?
- [ ] Testing evidence

Closes #{issue.iid}
        """
    except gitlab.exceptions.GitlabCreateError as err:
        print(f"Create issue failed. See log for more info.")
        logging.error(f"Create issue failed. Body: {issue_body}. Error: {err}")
        return

    mr_body = {
        "source_branch": branch_name,
        "target_branch": target_branch,
        "title": title,
        "description": mr_description,
        "assignee_id": user_id,
        "squash": True,
        "remove_source_branch": True,
        "draft": False,
		# "labels": ["AWAITING DEV REVIEW"]
    }

    try:
        mr = project.mergerequests.create(mr_body)
        print(f"Merge request created successfully: {mr.web_url}")
    except gitlab.exceptions.GitlabCreateError as err:
        print(f"Create MR failed. See log for more info.")
        logging.error(f"Create MR failed. Body: {mr_body}. Error: {err}")

if __name__ == "__main__":
    if len(sys.argv) > 6:
        create_mr(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5], sys.argv[6])
    else:
        create_mr(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5], "")
