#
# develop.yml
# LearnCHANGELOG
#
# Created by west on 04/11/25.
# Updated: Fixed formatting and enhanced logic
#

name: Development Changelog

on:
  # Ketika ada push langsung ke develop atau main
  push:
    branches: 
      - develop
      - main
  
  # Ketika PR di-merge ke develop atau main
  pull_request:
    types: [closed]
    branches:
      - develop
      - main

permissions:
  contents: write

jobs:
  changelog-dev:
    name: Generate Development Changelog
    runs-on: ubuntu-latest
    # Hanya run jika push atau PR merged (bukan PR closed tanpa merge)
    if: github.event_name == 'push' || (github.event_name == 'pull_request' && github.event.pull_request.merged == true)
    
    steps:
      - name: Checkout Repository
        uses: actions/checkout@v4
        with:
          fetch-depth: 0  # Fetch all history untuk changelog
          token: ${{ secrets.GITHUB_TOKEN }}
          ref: ${{ github.event.pull_request.base.ref || github.ref }}

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Install conventional-changelog-cli
        run: npm install -g conventional-changelog-cli

      - name: Generate Development Changelog
        run: |
          echo "Generating development changelog..."
          
          # Generate changelog dari semua commits
          conventional-changelog -p angular -i CHANGELOG-DEV.md -s -r 0
          
          # Jika file kosong atau tidak ada, buat header
          if [ ! -s CHANGELOG-DEV.md ]; then
            cat > CHANGELOG-DEV.md << 'EOF'
          # Development Changelog
          
          All notable development changes will be documented in this file.
          
          This changelog is for internal development team and includes:
          - Features (feat)
          - Bug Fixes (fix)
          - Refactoring (refactor)
          - Performance Improvements (perf)
          - Chores (chore) - dependencies, configs
          - Tests (test)
          - Documentation (docs)
          - Code Style (style)
          - Build System (build)
          - CI/CD (ci)
          
          For user-facing changes only, see CHANGELOG.md
          
          ---
          
          EOF
            # Re-generate setelah header dibuat
            conventional-changelog -p angular -i CHANGELOG-DEV.md -s -r 0
          fi
          
          echo "Development changelog generated"

      - name: Generate Release Changelog (User-facing)
        run: |
          echo "Generating release changelog..."
          
          # Generate changelog hanya untuk feat dan fix (user-facing)
          conventional-changelog -p angular -i CHANGELOG.md -s
          
          # Jika file kosong atau tidak ada, buat header
          if [ ! -s CHANGELOG.md ]; then
            cat > CHANGELOG.md << 'EOF'
          # Changelog
          
          All notable user-facing changes will be documented in this file.
          
          This changelog includes only:
          - New Features
          - Bug Fixes
          
          For internal/technical changes, see CHANGELOG-DEV.md
          
          ---
          
          EOF
            # Re-generate setelah header dibuat
            conventional-changelog -p angular -i CHANGELOG.md -s
          fi
          
          echo "Release changelog generated"

      - name: Check for Changes
        id: check_changes
        run: |
          # Check if changelogs have changes
          git diff --exit-code CHANGELOG-DEV.md CHANGELOG.md > /dev/null 2>&1 || echo "changed=true" >> $GITHUB_OUTPUT
          
          if [ "${{ steps.check_changes.outputs.changed }}" != "true" ]; then
            echo "changed=false" >> $GITHUB_OUTPUT
            echo "ℹNo changes detected in changelogs"
          else
            echo "Changes detected in changelogs"
          fi

      - name: Commit and Push Changes
        if: steps.check_changes.outputs.changed == 'true'
        run: |
          git config --local user.email "github-actions[bot]@users.noreply.github.com"
          git config --local user.name "github-actions[bot]"
          
          git add CHANGELOG-DEV.md CHANGELOG.md
          
          # Commit message tergantung context
          if [ "${{ github.event_name }}" == "pull_request" ]; then
            COMMIT_MSG="chore(changelog): update changelogs after PR #${{ github.event.pull_request.number }} [skip ci]"
          else
            COMMIT_MSG="chore(changelog): auto-update changelogs [skip ci]"
          fi
          
          git commit -m "$COMMIT_MSG"
          git push origin ${{ github.event.pull_request.base.ref || github.ref_name }}
          
          echo "Changelogs committed and pushed"

      - name: Create Job Summary
        if: always()
        run: |
          echo "## Changelog Generation Summary" >> $GITHUB_STEP_SUMMARY
          echo "" >> $GITHUB_STEP_SUMMARY
          
          if [ "${{ steps.check_changes.outputs.changed }}" == "true" ]; then
            echo "### Success" >> $GITHUB_STEP_SUMMARY
            echo "" >> $GITHUB_STEP_SUMMARY
            echo "Changelogs have been updated:" >> $GITHUB_STEP_SUMMARY
            echo "- **CHANGELOG-DEV.md** - All development changes" >> $GITHUB_STEP_SUMMARY
            echo "- **CHANGELOG.md** - User-facing changes only" >> $GITHUB_STEP_SUMMARY
            echo "" >> $GITHUB_STEP_SUMMARY
            
            if [ "${{ github.event_name }}" == "pull_request" ]; then
              echo "**Triggered by:** PR #${{ github.event.pull_request.number }} merged to \`${{ github.event.pull_request.base.ref }}\`" >> $GITHUB_STEP_SUMMARY
            else
              echo "**Triggered by:** Push to \`${{ github.ref_name }}\`" >> $GITHUB_STEP_SUMMARY
            fi
          else
            echo "###  No Changes" >> $GITHUB_STEP_SUMMARY
            echo "" >> $GITHUB_STEP_SUMMARY
            echo "Changelogs are already up to date." >> $GITHUB_STEP_SUMMARY
            echo "No new conventional commits detected since last update." >> $GITHUB_STEP_SUMMARY
          fi
          
          echo "" >> $GITHUB_STEP_SUMMARY
          echo "---" >> $GITHUB_STEP_SUMMARY
          echo "_Generated by GitHub Actions_" >> $GITHUB_STEP_SUMMARY