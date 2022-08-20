# Fixing characters with sed that Day One escapes: .()-![]
s/\\\././g
s/\\(/(/g
s/\\)/)/g
s/\\-/-/g
s/\\!/!/g
s/\\\[/[/g
s/\\\]/]/g
