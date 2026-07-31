# Publishes local changes to https://csw007.github.io/handyman-jobs-app/
# Run this from PowerShell after editing handyman-jobs.html or handyman-office.html.
# GitHub Pages auto-rebuilds within ~1 minute of the push landing on main.

Set-Location $PSScriptRoot
git add -A

$status = git status --porcelain
if (-not $status) {
    Write-Output "Nothing changed - nothing to deploy."
    exit 0
}

$message = Read-Host "Describe this change (e.g. 'fix job timer bug')"
if (-not $message) { $message = "Update app" }

git commit -m "$message"
git push

Write-Output ""
Write-Output "Pushed. Live in ~1 minute at:"
Write-Output "  https://csw007.github.io/handyman-jobs-app/handyman-jobs.html"
Write-Output "  https://csw007.github.io/handyman-jobs-app/handyman-office.html"
