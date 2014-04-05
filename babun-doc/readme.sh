readme="../README.adoc"

echo "" > "$readme"

cat adoc/preface.adoc >> "$readme"
cat adoc/usage.adoc >> "$readme"
cat adoc/development.adoc >> "$readme"