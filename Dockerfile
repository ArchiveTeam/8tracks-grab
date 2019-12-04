FROM warcforceone/grab-base
COPY . /grab
RUN wget -O /grab/wget-lua http://xor.meo.ws/vUO6LyuhBlMOqGUjZ3sFQCqUcR83pl9N/wget-lua \
 && chmod +x /grab/wget-lua
