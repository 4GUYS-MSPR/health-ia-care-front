# Environemnt to install flutter and build web
FROM debian:bookworm-slim AS build-env

# install all needed stuff
RUN apt-get update \
	&& apt-get install -y --no-install-recommends curl git unzip xz-utils ca-certificates \
	&& rm -rf /var/lib/apt/lists/*

# define variables
ARG FLUTTER_SDK=/usr/local/flutter
ARG APP=/app/

#clone flutter
RUN git clone --depth 1 https://github.com/flutter/flutter.git $FLUTTER_SDK
# change dir to current flutter folder and make a checkout to the specific version
RUN cd $FLUTTER_SDK && git fetch --depth 1 && git checkout 3.38.7

# setup the flutter path as an enviromental variable
ENV PATH="$FLUTTER_SDK/bin:$FLUTTER_SDK/bin/cache/dart-sdk/bin:${PATH}"

# Start to run Flutter commands
# ensure web is enabled for build
RUN flutter config --enable-web

# create folder to copy source code
RUN mkdir $APP
# copy source code to folder
COPY . $APP
# stup new folder as the working directory
WORKDIR $APP

# Run build: 1 - clean, 2 - pub get, 3 - build web
RUN flutter clean \
	&& flutter pub get \
	&& flutter build web

# once heare the app will be compiled and ready to deploy

# use nginx to deploy
FROM nginx:1.25.2-alpine

# copy the info of the builded web app to nginx
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Expose and run nginx
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]