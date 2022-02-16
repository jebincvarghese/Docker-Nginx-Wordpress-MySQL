FROM nginx
RUN rm -rf /etc/nginx/default.d/*
COPY ./default.conf /etc/nginx/conf.d/default.conf
COPY ./jebincvarghese.xyz.crt /etc/nginx/jebincvarghese.xyz.crt
COPY ./jebincvarghese.xyz.key /etc/nginx/jebincvarghese.xyz.key
