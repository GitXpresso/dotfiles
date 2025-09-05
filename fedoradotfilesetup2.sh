export number='^[0-9]\+$'
is_fast=$(grep -q "fastestmirror=True" /etc/dnf/dnf.conf && echo yes || echo no)
is_yes=$(grep -q "defaultyes=True" /etc/dnf/dnf.conf && echo yes || echo no)
is_delta=$(grep -q "deltarpm=True" /etc/dnf/dnf.conf && echo yes || echo no)
is_cache=$(grep -q "keepcache=True" /etc/dnf/dnf.conf && echo yes || echo no)
is_parallel_downloads=$(grep -q "max_parallel_downloads=$number" /etc/dnf/dnf.conf && echo yes || echo no)

echo 
"
1. Add Fast Repositories (Allows faster dnf installs) [ Available = $is_fast ] 
2. Enable Default Prompt to \"Y\" instead of \"N\" when installing packages [ Available = $is_yes ] 
3. Enable DeltaRPM (Downloads only the differences between package versions, saving bandwidth) [ Available = $is_delta ] 
4. Set Keep Cache value to true (Keeps the downloaded packages in cache, useful for reinstalls or debugging) [ Available = $is_cache ]
5. Enable Parallel Downloads ( installs multiple packages simultaneously ) [ Available = $is_parallel_downloads ]
"
