push=$(git config --global push.default || echo "")
version=$(git --version || echo "")

if [[ $version == *" 1."* ]]; then
	if [[ "$push" != "nothing" && "$push" != "matching" && "$push" != "tracking" && "$push" != "current" ]]; then
		echo "WARNING: Git push strategy set to [$push] which is unsupported - changing to 'matching'"
	    git config --global push.default "matching" || echo "ERROR: Cannot set git push.default to 'matching' - may cause problems..."
	fi
else 
	if [[ "$push" != "nothing" && "$push" != "matching" && "$push" != "simple" && "$push" != "upstream" && "$push" != "current" ]]; then
		echo "WARNING: Git push strategy set to $push which is unsupported - changing to 'matching'"
	    git config --global push.default "matching" || echo "ERROR: Cannot set git push.default to 'matching' - may cause problems..."
	fi
fi

git config --global core.trustctime false