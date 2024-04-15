name: goreleaser

on:
  # Only run when triggered through the Github UI or API.
  workflow_dispatch:

permissions:
  contents: write
  packages: write

concurrency:
  group: {{ .Config.Name }}-release-{{ "${{" }} github.head_ref {{ "}}" }}
  cancel-in-progress: true

jobs:
  goreleaser:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
          fetch-tags: true
      - uses: jdx/mise-action@v2
        with:
          experimental: true
        env:
          GH_TOKEN: {{ "${{" }} github.token {{ "}}" }}
      - name: Retrieve goreleaser version
        run: |
          echo "version=$(mise current goreleaser)" >> "$GITHUB_OUTPUT"
        id: goreleaser
      - name: Login to GitHub Container Registry
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: {{ "${{" }} github.actor {{ "}}" }}
          password: {{ "${{" }} secrets.GITHUB_TOKEN {{ "}}" }}
      - uses: goreleaser/goreleaser-action@v5
        with:
          distribution: goreleaser
          version: v{{ "${{" }} steps.goreleaser.outputs.version {{ "}}" }}
          args: release --clean
        env:
          GITHUB_TOKEN: {{ "${{" }} secrets.GITHUB_TOKEN {{ "}}" }}