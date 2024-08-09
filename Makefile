# Install dependencies
install:
	yarn

# Copy externally built assets from the stencila/stencile repo
external:
	rm -rf extensions/stencila/
	cp -r ../stencila/vscode/ extensions/stencila
	cp ../stencila/target/x86_64-unknown-linux-gnu/release/stencila .

# Build the desktop app
desktop: install external
	yarn compile

# Run the desktop app
desktop-run:
	./scripts/code.sh

# Build the server image
server: external
	docker build --platform linux/amd64 --tag stencila/writer .

# Run the server image
server-run:
	docker run --rm --privileged --platform linux/amd64 --publish 8080:80 stencila/writer

# Start a shell (and skip starting the server) for debugging
server-debug:
	docker run --rm --privileged --platform linux/amd64 --publish 8080:80 --entrypoint /bin/bash --interactive --tty stencila/writer
