# Manage Jekyll through Docker

Docker images for generating sites with Jekyll

## Usage

Images doesn't directly contain Jekyll. It must be provided through a gem local to your project. So, workspace must be mounted with your "identity" to `/data`:

```bash
# Update gems
docker run --rm -ti -v "$(pwd):/data" -u "$(id -u)" loganmzz/jekyll bundle install

# Buid site
docker run --rm -ti -v "$(pwd):/data" -u "$(id -u)" loganmzz/jekyll bundle exec jekyll build

# Serve
docker run --rm -ti -v "$(pwd):/data" -u "$(id -u)" -p 4000:4000 loganmzz/jekyll bundle exec jekyll serve -H 0.0.0.0
```


## Versions

Tags don't match with component version. Instead here is the version matrix:

| Image tag | Ruby   | Bundler | Node.js |
| --------- | ------ | ------- | ------- |
| latest    | 2.5.0  | 1.16.1  | 9.5.0   |
| 1.0.0     | 2.5.0  | 1.16.1  | 9.5.0   |

