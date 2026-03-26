# ──────────────────────────────────────────────────────────────────────────────
# Kenwell Health App — developer shortcuts
# Usage: make <target>
#
# Prerequisites
#   • Flutter SDK ≥ 3.32  (flutter doctor)
#   • Firebase CLI        (npm install -g firebase-tools && firebase login)
#   • FIREBASE_SERVICE_ACCOUNT_KENWELLMOBILEAPP secret set in GitHub Actions
#     (run: firebase init hosting:github)
# ──────────────────────────────────────────────────────────────────────────────

.PHONY: help get generate serve build deploy-staging deploy-preview promote-staging clean

# Default target — print available commands
help:
	@echo ""
	@echo "  Kenwell Health App — developer commands"
	@echo ""
	@echo "  ── Development ───────────────────────────────────────────────────"
	@echo "  make get              flutter pub get"
	@echo "  make generate         dart run build_runner build (Drift + mocks)"
	@echo "  make serve            run the web app locally in Chrome (hot reload)"
	@echo "  make serve-port       run on http://localhost:8080 (no browser)"
	@echo "  make test             flutter test --coverage"
	@echo ""
	@echo "  ── Build ─────────────────────────────────────────────────────────"
	@echo "  make build            flutter build web --release (CanvasKit renderer)"
	@echo ""
	@echo "  ── Firebase Hosting ──────────────────────────────────────────────"
	@echo "  make deploy-staging   build + deploy to the 'staging' channel"
	@echo "                        URL: https://kenwellmobileapp--staging-<hash>.web.app"
	@echo "  make deploy-preview   build + deploy to a one-off preview channel"
	@echo "                        (expires in 7 days)"
	@echo "  make promote-staging  copy the staging release directly to production"
	@echo "                        (zero rebuild, instant promotion)"
	@echo ""
	@echo "  ── Housekeeping ──────────────────────────────────────────────────"
	@echo "  make clean            remove build/ directory"
	@echo ""

# ── Development ───────────────────────────────────────────────────────────────

get:
	flutter pub get

generate: get
	dart run build_runner build --delete-conflicting-outputs

# Opens the app in Chrome with hot-reload enabled.
# Change --web-renderer to html if CanvasKit is too slow on your machine.
serve: get generate
	flutter run -d chrome --web-renderer canvaskit

# Headless web server — useful for remote machines / CI debugging.
# Open http://localhost:8080 in any browser.
serve-port: get generate
	flutter run -d web-server --web-port 8080 --web-hostname 0.0.0.0 --web-renderer canvaskit

test: get generate
	flutter test --coverage

# ── Build ─────────────────────────────────────────────────────────────────────

build: get generate
	flutter build web --release --web-renderer canvaskit

# ── Firebase Hosting ──────────────────────────────────────────────────────────

# Deploy to the persistent 'staging' channel.
# Staging URL is printed after the command finishes.
# The URL format is: https://kenwellmobileapp--staging-<random>.web.app
deploy-staging: build
	firebase hosting:channel:deploy staging --project kenwellmobileapp

# Deploy to a one-off preview channel (expires in 7 days).
# Pass a name: make deploy-preview CHANNEL=my-feature
CHANNEL ?= preview-$(shell date +%Y%m%d-%H%M)
deploy-preview: build
	firebase hosting:channel:deploy $(CHANNEL) --expires 7d --project kenwellmobileapp

# Promote the current staging release straight to production (live channel).
# This is the recommended way to go to production — no re-build required.
# Equivalent to: firebase hosting:clone staging → live
promote-staging:
	firebase hosting:clone kenwellmobileapp:staging kenwellmobileapp:live

# ── Housekeeping ──────────────────────────────────────────────────────────────

clean:
	rm -rf build/