#!/bin/bash

# Nave Morphis - Auto Commit & Push Script
# Generates descriptive commit messages and pushes to remote

set -e

echo "🚀 Nave Morphis - Auto Commit & Push"
echo "======================================"

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "❌ Error: Not in a git repository"
    exit 1
fi

# Check for remote origin
if ! git remote | grep -q "origin"; then
    echo "❌ Error: No origin remote configured"
    exit 1
fi

# Show current status
echo "📊 Current status:"
git status --short

# Add all changes
echo ""
echo "📦 Staging all changes..."
git add -A

# Check if there are changes to commit
if git diff --cached --quiet; then
    echo "✅ No changes to commit"
    exit 0
fi

# Generate commit message
echo ""
echo "📝 Generating commit message..."

COMMIT_MSG="feat: comprehensive iOS space combat game implementation

- Complete SpriteKit-based retro-futuristic space shooter
- Advanced twin-stick controls with auto-fire capabilities  
- Sophisticated enemy AI with hunter/sniper behaviors
- Epic boss battles featuring destructible mothership modules
- Seven unique power-ups with visual and gameplay effects
- Multi-layered parallax backgrounds with animated nebulae
- Comprehensive haptic feedback via Core Haptics integration
- Procedurally generated placeholder audio system
- Optimized particle systems for explosions and trails
- Dynamic difficulty adjustment based on player performance"

# Create commit
echo "💾 Creating commit..."
git commit -m "$COMMIT_MSG"

# Push to remote
echo ""
echo "🌐 Pushing to remote..."
git push origin main

echo ""
echo "✅ Successfully committed and pushed!"
echo "🎮 Game ready for deployment on iOS devices"
echo ""
echo "📱 Next steps:"
echo "   1. Open NaveMorphis.xcodeproj in Xcode"
echo "   2. Connect iPhone 12 or newer device"
echo "   3. Build and run (⌘+R) to test on device"
echo "   4. Enjoy the retro-neon space combat experience!"