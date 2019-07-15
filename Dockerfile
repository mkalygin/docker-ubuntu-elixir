FROM ubuntu:18.04

LABEL maintainer="Michael Kalygin <michael.kalygin@gmail.com>"
LABEL updated_at="2019-07-13"

# Set environment.
ENV ERLANG_VERSION 22.0.4
ENV ELIXIR_VERSION 1.9.0
ENV NODEJS_VERSION 10.16.0

ENV APP_USER app
ENV HOME /home/$APP_USER
ENV ASDF_DATA_DIR $HOME/.asdf
ENV PATH $ASDF_DATA_DIR/bin:$ASDF_DATA_DIR/shims:$PATH

# Install packages.
RUN apt-get update -q && \
    apt-get install -y git curl locales build-essential autoconf unixodbc-dev \
                       libncurses5-dev libwxgtk3.0-dev libgl1-mesa-dev \
                       libglu1-mesa-dev libpng-dev libssh-dev inotify-tools

# Set locale.
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Create user for app.
RUN groupadd --gid 1000 $APP_USER && \
    useradd --uid 1000 --gid $APP_USER --shell /bin/bash --create-home $APP_USER

# Install asdf.
RUN git clone https://github.com/asdf-vm/asdf.git $ASDF_DATA_DIR && \
    asdf plugin-add erlang && \
    asdf plugin-add elixir && \
    asdf plugin-add nodejs && \
    $ASDF_DATA_DIR/plugins/nodejs/bin/import-release-team-keyring

# Install Erlang.
RUN asdf install erlang ${ERLANG_VERSION} && \
    asdf global erlang ${ERLANG_VERSION}

# Install Elixir.
RUN asdf install elixir ${ELIXIR_VERSION} && \
    asdf global elixir ${ELIXIR_VERSION}

# Install Node.js.
RUN asdf install nodejs ${NODEJS_VERSION} && \
    asdf global nodejs ${NODEJS_VERSION}

# Install hex and rebar.
RUN mix local.hex --force && \
    mix local.rebar --force

# Own asdf as app user.
RUN chown -hR $APP_USER $HOME
