.PHONY: build run

all: build run

# Build the theia container
build:
	docker build -t theia-custom:next .

# Run the prepared theia container with current folder as project root
run:
	docker run --rm -it -v $(realpath .):/home/project:cached -p3000:3000 theia-custom:next

# Spawn a shell in the container
shell:
	docker run --rm -it -v --detach-keys="ctrl-@" -p3000:3000 --entrypoint /bin/bash theia-custom:next
