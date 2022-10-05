
# build the image
docker build -f Builder.dockerfile . -t ghcr.io/mintbase/diesel-builder

# ensure it runs
docker run -v $(PWD):/builder diesel-builder hasura metadata version || exit 1

# push to github container repository (see note about login in README)
docker push ghcr.io/mintbase/diesel-builder:latest