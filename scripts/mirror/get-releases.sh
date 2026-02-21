#!/bin/sh -e
d=git-archive
[ ! -e ../$d ] || d=../$d
[ -e $d ] || mkdir $d
r=$d/releases/

repo=sipeed/MaixCDK

   if release=$(curl -fqs https://api.github.com/repos/sipeed/MaixCDK/releases | jq -r '.[] | select(.tag_name | match("^v0.0.0$"))')
    then
      tag="$(echo "$release" | jq -r '.tag_name')"
      rel_files="$(echo "$release" | jq -r '.assets[] | .name')"
      echo "Parsing repo $repo at $tag"
      for rel_file in $rel_files ; do
      if [ -n "$rel_file" ]
      then
        echo "Getting ${rel_file}"
        mkdir -p "${r}/${repo}/releases/download/${tag}"
        pushd "${r}/${repo}/releases/download/${tag}" >/dev/null
        wget -q -N "https://github.com/${repo}/releases/download/${tag}/${rel_file}"
        popd >/dev/null
      fi
      done
   fi

echo OK
