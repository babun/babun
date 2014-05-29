push=$(git config --global push.default || echo "")
if [[ "$push" == "simple" ]]; then
    echo "WARNING: Git push strategy set to 'simple' which is unsupported - changing to 'matching'"
    git config --global push.default "matching" || echo "ERROR: Cannot set git push.default to 'matching' - may cause problems..."
fi