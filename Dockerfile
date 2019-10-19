FROM google/dart

WORKDIR /app

COPY pubspec.* /app/
RUN pub get
COPY . /app/
RUN pub get --offline

RUN dart2aot bin/main.dart server.aot

EXPOSE 9090

CMD ["/bin/bash", "-c", "dartaotruntime server.aot"]
