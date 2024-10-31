find / -type f \( -perm -2 -o -perm -20 \) -exec ls -lg {} \; 2>/dev/null
find / -type d \( -perm -2 -o -perm -20 \) -exec ls -ldg {} \; 2>/dev/null
