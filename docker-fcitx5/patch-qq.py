import sys

path = "/woc/app-ctl.sh"
try:
    with open(path) as f:
        lines = f.readlines()
    new_lines = []
    patched = False
    for line in lines:
        new_lines.append(line)
        if ': "${total:=0}"' in line and not patched and 'fallback_url' not in "".join(lines):
            patched = True
            new_lines.append('''  if [ "$total" -eq 0 ]; then
    fallback_url="https://qqdl.gtimg.cn/qqfile/QQNT/9.9.36/beta/9ee04bef/linuxqq_${ver}-53644_${arch}.deb"
    if curl -fsSLI --connect-timeout 5 "$fallback_url" >/dev/null 2>&1; then
      url="$fallback_url"
      echo "$url" > "$work/qq.url"
      total=$(curl -fsSLI --connect-timeout 10 -A "$QQ_UA" "$url" 2>/dev/null | awk 'tolower($1)=="content-length:"{v=$2} END{print v}')
      : "${total:=0}"
    fi
  fi
''')
    with open(path, "w") as f:
        f.writelines(new_lines)
    print("QQ download fallback patched successfully.")
except Exception as e:
    print(f"Notice: patch skipped or failed: {e}")
