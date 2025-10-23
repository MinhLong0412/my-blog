#!/bin/bash

# Start Hugo development server with local config
echo "🚀 Starting Hugo development server..."
echo "📂 Blog will be available at: http://localhost:1313/"
echo "🔄 Watching for changes..."
echo ""

hugo server -D --config hugo.dev.toml
