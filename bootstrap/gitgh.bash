# Only attempt git pull if gh auth is working (prevent hang on expired/missing PAT)
if command -v gh &>/dev/null; then
  if gh auth status &>/dev/null; then
    git pull &
  else
    echo "Warning: GitHub CLI not authenticated. Skipping git pull."
  fi
else
  echo "Warning: GitHub CLI (gh) not installed. Skipping git pull."
fi
