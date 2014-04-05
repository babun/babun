readme="../README.adoc"

cat /dev/null > "$readme"

cat adoc/header.adoc >> "$readme"
cat adoc/usage.adoc >> "$readme"
cat adoc/development.adoc >> "$readme"
cat adoc/licence.adoc >> "$readme"
cat adoc/footer.adoc >> "$readme"