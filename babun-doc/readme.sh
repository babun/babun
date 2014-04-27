#!/bin/bash
set -e -f -o pipefail

readme="../README.adoc"
cat /dev/null > "$readme"

cat adoc/header.adoc >> "$readme"
cat adoc/screencast.adoc >> "$readme"
cat adoc/installation.adoc >> "$readme"
cat adoc/usage.adoc >> "$readme"
cat adoc/development.adoc >> "$readme"
cat adoc/licence.adoc >> "$readme"
cat adoc/supporters.adoc >> "$readme"
cat adoc/footer.adoc >> "$readme"