#!/bin/bash
set -e -f -o pipefail

readme="../README.adoc"
cat /dev/null > "$readme"

echo "// THIS DOCUMENT WAS GENERATED. DO NOT EDIT IT.\n" >> adoc/_header.adoc

cat adoc/_header.adoc >> "$readme"
cat adoc/_screencast.adoc >> "$readme"
cat adoc/_installation.adoc >> "$readme"
cat adoc/_usage.adoc >> "$readme"
cat adoc/_screenshots.adoc >> "$readme"
cat adoc/_development.adoc >> "$readme"
cat adoc/_licence.adoc >> "$readme"
cat adoc/_supporters.adoc >> "$readme"
cat adoc/_footer.adoc >> "$readme"
