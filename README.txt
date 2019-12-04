xzcat ../export_channel_ids.txt.xz | head | ./2url | wget-lua -U ArchiveTeam --lua playlist.lua -nv --output-document wget.tmp --truncate-output  -i - --warc-file test
