# Publishing

CurseForge project: 1766097 (`patchtoolsbags`). Required dependency: `patchtools`.

Publish normal releases from `main`, preserving `alpha/prototype` for prototype history.
CurseForge should package tagged commits only. Use a plain release tag such as
`v0.1.0` for a Release; prerelease tags must include alpha/beta as appropriate.

Push the branch first and allow its webhook delivery to finish before creating
and pushing the tag. Never push branch and tag together or use `--follow-tags`:
separate simultaneous push events caused duplicate packages in the map module.
Create the GitHub release against the already pushed tag. Do not upload the same
package manually to CurseForge when its automatic build is running.

Check the single intended CurseForge build/file and record moderation status.
Do not claim availability in the CurseForge client before project/file approval.
