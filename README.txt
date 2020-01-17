Checkout:
  git clone https://github.com/ArchiveTeam/8tracks-grab
  cd 8tracks-grab

Running with Docker: 
  docker build .
  docker run $HASH $USERNAME

Running with scripts:
  Install Deps:
    apt-get update && apt-get install -y git-core libgnutls28-dev lua5.1 liblua5.1-0 liblua5.1-0-dev screen python-dev python-pip bzip2 zlib1g-dev flex autoconf autopoint texinfo gperf python3 python3-pip lua-socket nload automake m4 pkg-config gcc g++

  Build wget-lua:
    ./get-wget-lua.sh
  
  Install seesaw:
    pip3 install seesaw

  Run:
    run-pipeline3 ./pipeline.py $USERNAME

Watch:
  http://tracker.archiveteam.org/8tracks/

Chat:
  /join #8tracks on  irc.hackint.org  [ https://hackint.org/ ]
