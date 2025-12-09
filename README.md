[![Deploy](https://github.com/humbertodias/docker-allegro-compiler/actions/workflows/deploy.yml/badge.svg)](https://github.com/humbertodias/docker-allegro-compiler/actions/workflows/deploy.yml)

# docker-allegro-compiler

### How to use

- v5
```shell
ALLEGRO_VERSION=5.2.9.1
ALLEGRO_PROJECT_PATH="~/my-sdl-project"
ALLEGRO_PROJECT_COMPILER_CMD="g++ main.cpp -o main -g `pkg-config --cflags --static --libs allegro-5`"
docker run -v $ALLEGRO_PROJECT_PATH:/tmp/workdir \
-w /tmp/workdir \
-ti hldtux/allegro-compiler:$ALLEGRO_VERSION-mingw-w64-i686 \
bash -c "$ALLEGRO_PROJECT_COMPILER_CMD"
```

- v4
```shell
ALLEGRO_VERSION=4.4.3.1
ALLEGRO_PROJECT_PATH="~/my-sdl-project"
ALLEGRO_PROJECT_COMPILER_CMD="g++ main.cpp -o main -g `allegro-config --libs --cflags --static`"
docker run -v $ALLEGRO_PROJECT_PATH:/tmp/workdir \
-w /tmp/workdir \
-ti hldtux/allegro-compiler:$ALLEGRO_VERSION-mingw-w64-i686 \
bash -c "$ALLEGRO_PROJECT_COMPILER_CMD"
```
