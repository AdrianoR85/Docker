FROM postgres:18.1

RUN apt-get update && \
    apt-get install -y locales && \
    sed -i '/pt_BR.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen pt_BR.UTF-8 && \
    rm -rf /var/lib/apt/lists/*

ENV LANG pt_BR.UTF-8
ENV LC_ALL pt_BR.UTF-8