
# build the image
docker buildx build --no-cache --platform linux/amd64 -f Builder.dockerfile . -t ghcr.io/mintbase/diesel-builder:latest || exit 1

# ensure it runs
docker run -v $(PWD):/builder --rm -it --entrypoint='' ghcr.io/mintbase/diesel-builder:latest hasura metadata version || exit 1

# push to github container repository (see note about login in README)
docker push ghcr.io/mintbase/diesel-builder:latest