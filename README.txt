wget https://archive.org/download/test_20191203_20191203/export_channel_ids.txt.xz
xzcat export_channel_ids.txt.xz | head | ./2url | wget-lua -U ArchiveTeam --lua playlist.lua -nv --output-document wget.tmp --truncate-output  -i - --warc-file test
